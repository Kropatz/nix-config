#!/usr/bin/env python3
"""Generate OpenObserve dashboards (schema v8) and alerts for the suricata eve stream.

Usage: python3 generate.py modules/opt-impl/nixos/services/openobserve-dashboards

Writes suricata-network.json and suricata-security.json (Dashboards -> Import)
suricata-alerts.json (Alerts -> Import) and suricata-template.json, the
notification template (Management -> Templates -> Import).

Column names are the eve fields after openobserve's flattening (nested keys
joined with "_"), plus dns_rrname/dns_rrtype/dns_answer which the fluent-bit
lua filter in suricata.nix adds. _timestamp is int64 microseconds.
"""
import json
import re
import sys
from pathlib import Path

STREAM = "suricata"
ORG = "default"
DESTINATION = "homelab"  # create this destination in openobserve, or pick one on import
DNS_SERVERS = ["192.168.0.10"]  # adguard (custom.vars.serverIp)

F = f'FROM "{STREAM}"'
TS = "to_timestamp_micros(_timestamp)"


def private(col):
    return (
        f"({col} LIKE '192.168.%' OR {col} LIKE '10.%' OR {col} LIKE '172.16.%' "
        f"OR {col} LIKE '172.17.%' OR {col} LIKE '172.18.%' OR {col} LIKE '172.19.%' "
        f"OR {col} LIKE '172.2_.%' OR {col} LIKE '172.30.%' OR {col} LIKE '172.31.%' "
        f"OR {col} LIKE 'fe80:%' OR {col} LIKE 'fd%' OR {col} LIKE 'fc%' "
        f"OR {col} LIKE '127.%' OR {col} = '::1')"
    )


def noise(col):
    # multicast / broadcast / link-local
    return (
        f"({col} LIKE '224.%' OR {col} LIKE '239.%' OR {col} = '255.255.255.255' "
        f"OR {col} LIKE '%.255' OR {col} LIKE 'ff0%' OR {col} LIKE '169.254.%')"
    )


SRC_INT = private("src_ip")
DST_INT = private("dest_ip")
SRC_EXT = f"NOT {SRC_INT}"
DST_EXT = f"NOT {DST_INT}"
NOT_NOISE = f"NOT {noise('dest_ip')}"
EGRESS = f"{SRC_INT} AND {DST_EXT}"
# private -> private traffic. Excluded from the IDS alerts and scan detection:
# internal http/basic auth, service discovery and monitoring are noise there.
NOT_LAN = f"NOT ({SRC_INT} AND {DST_INT})"
FLOW = "event_type = 'flow'"
DNS_LIST = ", ".join(f"'{ip}'" for ip in DNS_SERVERS)
BYTES = "(flow_bytes_toserver + flow_bytes_toclient)"
DIRECTION = (
    f"CASE WHEN {SRC_INT} AND {DST_INT} THEN 'lan' "
    f"WHEN {SRC_INT} THEN 'egress' "
    f"WHEN {DST_INT} THEN 'ingress' ELSE 'transit' END"
)
COMMON_PORTS = "22, 53, 80, 123, 443, 853, 993, 465, 587, 3478, 5349, 51820"

_ids = iter(range(1, 10_000))


def axis(alias, label, time=False):
    return {
        "label": label,
        "alias": alias,
        "column": alias,
        "type": "custom",
        "color": None,
        "functionName": "histogram" if time else None,
        "args": [],
        "isDerived": False,
    }


def panel(title, typ, sql, x=(), y=(), breakdown=(), layout=(0, 0, 96, 24),
          description="", unit=None, time_x=False, top_results=None):
    """x/y/breakdown: sequences of (alias, label). time_x marks x[0] as time."""
    pid = next(_ids)
    config = {
        "show_legends": typ not in ("metric", "table"),
        "legends_position": None,
        "decimals": 2 if unit in ("bytes", "percent") else 0,
        "line_thickness": None,
        "top_results": top_results,
        "y_axis_min": None,
        "y_axis_max": None,
        "axis_width": None,
        "axis_label_rotate": None,
        "axis_label_truncate_width": None,
        "base_map": {"type": "osm"},
        "map_view": {"zoom": 1, "lat": 0, "lng": 0},
        "connect_nulls": True,
        "no_value_replacement": "",
        "wrap_table_cells": False,
        "table_pagination": typ == "table",
        "table_pagination_rows_per_page": 15 if typ == "table" else None,
    }
    if unit:
        config["unit"] = unit
    lx, ly, lw, lh = layout
    return {
        "id": f"Panel_ID{pid:07d}",
        "type": typ,
        "title": title,
        "description": description,
        "config": config,
        "queryType": "sql",
        "queries": [
            {
                "query": " ".join(sql.split()),
                "vrlFunctionQuery": "",
                "customQuery": True,
                "fields": {
                    "stream": STREAM,
                    "stream_type": "logs",
                    "x": [axis(a, l, time_x and i == 0) for i, (a, l) in enumerate(x)],
                    "y": [axis(a, l) for a, l in y],
                    "z": [],
                    "breakdown": [axis(a, l) for a, l in breakdown],
                    "filter": {
                        "filterType": "group",
                        "logicalOperator": "AND",
                        "conditions": [],
                    },
                },
                "config": {"promql_legend": "", "limit": 0},
            }
        ],
        "layout": {"x": lx, "y": ly, "w": lw, "h": lh, "i": pid},
        "htmlContent": "",
        "markdownContent": "",
    }


def dashboard(title, description, tabs, period="6h"):
    return {
        "version": 8,
        "dashboardId": "",
        "title": title,
        "description": description,
        "role": "",
        "owner": "",
        "tabs": [
            {"tabId": f"tab{i}", "name": name, "panels": panels}
            for i, (name, panels) in enumerate(tabs)
        ],
        "variables": {"list": [], "showDynamicFilters": True},
        "defaultDatetimeDuration": {"type": "relative", "relativeTimePeriod": period},
    }


def metric(title, sql, x, unit=None, description=""):
    return panel(title, "metric", sql, y=[("y_axis_1", title)],
                 layout=(x, 0, 48, 12), unit=unit, description=description)


def timeseries(title, typ, sql_value, where, breakdown_expr=None, breakdown_label="",
               layout=(0, 0, 96, 26), unit=None, bucket=None, description="", top_results=None):
    hist = f"histogram(_timestamp, '{bucket}')" if bucket else "histogram(_timestamp)"
    where_sql = f"WHERE {where}" if where else ""
    if breakdown_expr:
        sql = (f"SELECT {hist} AS x_axis_1, {breakdown_expr} AS breakdown_1, {sql_value} AS y_axis_1 "
               f"{F} {where_sql} GROUP BY x_axis_1, breakdown_1 ORDER BY x_axis_1")
        bd = [("breakdown_1", breakdown_label)]
    else:
        sql = (f"SELECT {hist} AS x_axis_1, {sql_value} AS y_axis_1 "
               f"{F} {where_sql} GROUP BY x_axis_1 ORDER BY x_axis_1")
        bd = []
    return panel(title, typ, sql, x=[("x_axis_1", "Time")], y=[("y_axis_1", title)],
                 breakdown=bd, time_x=True, layout=layout, unit=unit,
                 description=description, top_results=top_results)


def table(title, sql, x, y, layout, unit=None, description=""):
    return panel(title, "table", sql, x=x, y=y, layout=layout, unit=unit, description=description)


def hbar(title, sql, xlabel, ylabel, layout, unit=None, description=""):
    return panel(title, "h-bar", sql, x=[("x_axis_1", xlabel)], y=[("y_axis_1", ylabel)],
                 layout=layout, unit=unit, description=description)


def donut(title, sql, xlabel, ylabel, layout, unit=None, description=""):
    return panel(title, "donut", sql, x=[("x_axis_1", xlabel)], y=[("y_axis_1", ylabel)],
                 layout=layout, unit=unit, description=description)


# ================================================================ network
net_overview = [
    metric("Events", f"SELECT count(*) AS y_axis_1 {F}", 0),
    metric("Alerts", f"SELECT count(*) AS y_axis_1 {F} WHERE event_type = 'alert'", 48),
    metric("Traffic", f"SELECT sum({BYTES}) AS y_axis_1 {F} WHERE {FLOW}", 96, unit="bytes",
           description="Bytes in both directions of all finished flows"),
    metric("Local hosts", f"SELECT count(DISTINCT src_ip) AS y_axis_1 {F} WHERE {FLOW} AND {SRC_INT}", 144),
    timeseries("Events by type", "area-stacked", "count(*)", "", "event_type", "Type",
               layout=(0, 12, 96, 26)),
    timeseries("Traffic by direction", "area-stacked", f"sum({BYTES})", FLOW, DIRECTION, "Direction",
               layout=(96, 12, 96, 26), unit="bytes",
               description="lan = private to private, egress = private to public, ingress = public to private"),
    timeseries("Traffic by application protocol", "area-stacked", f"sum({BYTES})", FLOW,
               "coalesce(app_proto, proto)", "Protocol", layout=(0, 38, 128, 26), unit="bytes"),
    donut("Protocol share",
          f"""SELECT coalesce(app_proto, proto) AS x_axis_1, sum({BYTES}) AS y_axis_1
              {F} WHERE {FLOW} GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 12""",
          "Protocol", "Bytes", layout=(128, 38, 64, 26), unit="bytes"),
    hbar("Top talkers",
         f"""SELECT src_ip AS x_axis_1, sum({BYTES}) AS y_axis_1
             {F} WHERE {FLOW} GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 15""",
         "Host", "Bytes", layout=(0, 64, 64, 30), unit="bytes"),
    hbar("Top destinations",
         f"""SELECT dest_ip AS x_axis_1, sum({BYTES}) AS y_axis_1
             {F} WHERE {FLOW} GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 15""",
         "Host", "Bytes", layout=(64, 64, 64, 30), unit="bytes"),
    hbar("Top services",
         f"""SELECT concat(proto, '/', CAST(dest_port AS VARCHAR)) AS x_axis_1, count(*) AS y_axis_1
             {F} WHERE {FLOW} AND dest_port IS NOT NULL
             GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 15""",
         "Port", "Flows", layout=(128, 64, 64, 30)),
    table("Top conversations",
          f"""SELECT src_ip AS x_axis_1, dest_ip AS x_axis_2, proto AS x_axis_3,
                     dest_port AS x_axis_4, app_proto AS x_axis_5,
                     sum(flow_bytes_toserver) AS y_axis_1, sum(flow_bytes_toclient) AS y_axis_2,
                     count(*) AS y_axis_3
              {F} WHERE {FLOW}
              GROUP BY x_axis_1, x_axis_2, x_axis_3, x_axis_4, x_axis_5
              ORDER BY y_axis_1 + y_axis_2 DESC LIMIT 200""",
          x=[("x_axis_1", "Source"), ("x_axis_2", "Destination"), ("x_axis_3", "Proto"),
             ("x_axis_4", "Port"), ("x_axis_5", "App")],
          y=[("y_axis_1", "Bytes sent"), ("y_axis_2", "Bytes received"), ("y_axis_3", "Flows")],
          layout=(0, 94, 192, 36)),
]

DNS_REQ = "event_type = 'dns' AND dns_type = 'request'"
DNS_RESP = "event_type = 'dns' AND dns_type = 'response'"
net_dns = [
    timeseries("Queries by record type", "area-stacked", "count(*)", DNS_REQ, "dns_rrtype", "Type",
               layout=(0, 0, 128, 26)),
    donut("Response codes",
          f"""SELECT dns_rcode AS x_axis_1, count(*) AS y_axis_1
              {F} WHERE {DNS_RESP} GROUP BY x_axis_1 ORDER BY y_axis_1 DESC""",
          "Rcode", "Responses", layout=(128, 0, 64, 26)),
    table("Top domains",
          f"""SELECT dns_rrname AS x_axis_1, count(*) AS y_axis_1, count(DISTINCT src_ip) AS y_axis_2
              {F} WHERE {DNS_REQ} GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 200""",
          x=[("x_axis_1", "Domain")], y=[("y_axis_1", "Queries"), ("y_axis_2", "Clients")],
          layout=(0, 26, 96, 36)),
    hbar("Top clients",
         f"""SELECT src_ip AS x_axis_1, count(*) AS y_axis_1
             {F} WHERE {DNS_REQ} GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 15""",
         "Client", "Queries", layout=(96, 26, 96, 36)),
    table("NXDOMAIN",
          f"""SELECT dns_rrname AS x_axis_1, dest_ip AS x_axis_2, count(*) AS y_axis_1
              {F} WHERE {DNS_RESP} AND dns_rcode = 'NXDOMAIN'
              GROUP BY x_axis_1, x_axis_2 ORDER BY y_axis_1 DESC LIMIT 200""",
          x=[("x_axis_1", "Domain"), ("x_axis_2", "Client")], y=[("y_axis_1", "Responses")],
          layout=(0, 62, 96, 34),
          description="Lots of NXDOMAIN from one client can mean a DGA / malware or a broken config"),
    table("Resolved addresses",
          f"""SELECT dns_rrname AS x_axis_1, dns_answer AS x_axis_2, count(*) AS y_axis_1
              {F} WHERE {DNS_RESP} AND dns_answer IS NOT NULL
              GROUP BY x_axis_1, x_axis_2 ORDER BY y_axis_1 DESC LIMIT 200""",
          x=[("x_axis_1", "Domain"), ("x_axis_2", "Answers")], y=[("y_axis_1", "Responses")],
          layout=(96, 62, 96, 34),
          description="Use this to map IPs from the flow panels back to names"),
]

net_tls_http = [
    table("TLS server names",
          f"""SELECT tls_sni AS x_axis_1, count(*) AS y_axis_1, count(DISTINCT src_ip) AS y_axis_2
              {F} WHERE event_type = 'tls' GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 200""",
          x=[("x_axis_1", "SNI")], y=[("y_axis_1", "Handshakes"), ("y_axis_2", "Clients")],
          layout=(0, 0, 96, 36)),
    table("QUIC server names",
          f"""SELECT quic_sni AS x_axis_1, count(*) AS y_axis_1, count(DISTINCT src_ip) AS y_axis_2
              {F} WHERE event_type = 'quic' AND quic_sni IS NOT NULL
              GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 200""",
          x=[("x_axis_1", "SNI")], y=[("y_axis_1", "Events"), ("y_axis_2", "Clients")],
          layout=(96, 0, 64, 36)),
    donut("TLS versions",
          f"""SELECT tls_version AS x_axis_1, count(*) AS y_axis_1
              {F} WHERE event_type = 'tls' GROUP BY x_axis_1 ORDER BY y_axis_1 DESC""",
          "Version", "Handshakes", layout=(160, 0, 32, 36)),
    table("HTTP hosts",
          f"""SELECT http_hostname AS x_axis_1, http_http_method AS x_axis_2, count(*) AS y_axis_1,
                     count(DISTINCT src_ip) AS y_axis_2
              {F} WHERE event_type = 'http' GROUP BY x_axis_1, x_axis_2 ORDER BY y_axis_1 DESC LIMIT 200""",
          x=[("x_axis_1", "Host"), ("x_axis_2", "Method")],
          y=[("y_axis_1", "Requests"), ("y_axis_2", "Clients")],
          layout=(0, 36, 96, 34), description="Plaintext HTTP only"),
    table("HTTP user agents",
          f"""SELECT http_http_user_agent AS x_axis_1, count(*) AS y_axis_1,
                     count(DISTINCT src_ip) AS y_axis_2
              {F} WHERE event_type = 'http' GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 200""",
          x=[("x_axis_1", "User agent")], y=[("y_axis_1", "Requests"), ("y_axis_2", "Clients")],
          layout=(96, 36, 96, 34)),
    table("SSH software",
          f"""SELECT src_ip AS x_axis_1, dest_ip AS x_axis_2,
                     ssh_client_software_version AS x_axis_3, ssh_server_software_version AS x_axis_4,
                     count(*) AS y_axis_1
              {F} WHERE event_type = 'ssh'
              GROUP BY x_axis_1, x_axis_2, x_axis_3, x_axis_4 ORDER BY y_axis_1 DESC LIMIT 200""",
          x=[("x_axis_1", "Client"), ("x_axis_2", "Server"), ("x_axis_3", "Client software"),
             ("x_axis_4", "Server software")],
          y=[("y_axis_1", "Sessions")], layout=(0, 70, 192, 30)),
]

net_hosts = [
    timeseries("Egress per local host", "line", f"sum({BYTES})", f"{FLOW} AND {EGRESS}",
               "src_ip", "Host", layout=(0, 0, 192, 28), unit="bytes", top_results=10),
    table("DHCP",
          f"""SELECT dhcp_client_mac AS x_axis_1, max(dhcp_hostname) AS x_axis_2,
                     max(dhcp_assigned_ip) AS x_axis_3, max({TS}) AS y_axis_1, count(*) AS y_axis_2
              {F} WHERE event_type = 'dhcp' AND dhcp_client_mac IS NOT NULL
              GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 200""",
          x=[("x_axis_1", "MAC"), ("x_axis_2", "Hostname"), ("x_axis_3", "Assigned IP")],
          y=[("y_axis_1", "Last seen"), ("y_axis_2", "Messages")],
          layout=(0, 28, 96, 34), description="Devices seen requesting leases"),
    table("Public peers per local host",
          f"""SELECT src_ip AS x_axis_1, count(DISTINCT dest_ip) AS y_axis_1,
                     count(DISTINCT dest_port) AS y_axis_2, sum(flow_bytes_toserver) AS y_axis_3
              {F} WHERE {FLOW} AND {EGRESS}
              GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 100""",
          x=[("x_axis_1", "Host")],
          y=[("y_axis_1", "Public peers"), ("y_axis_2", "Distinct ports"), ("y_axis_3", "Bytes sent")],
          layout=(96, 28, 96, 34)),
]

network = dashboard(
    "Suricata - network",
    f"What is on the wire, from suricata eve events in the '{STREAM}' stream",
    [("Overview", net_overview), ("DNS", net_dns), ("TLS & HTTP", net_tls_http), ("Hosts", net_hosts)],
)

# =============================================================== security
ALERT = f"event_type = 'alert' AND {NOT_LAN}"
sec_alerts = [
    metric("Alerts", f"SELECT count(*) AS y_axis_1 {F} WHERE {ALERT}", 0),
    metric("High severity", f"SELECT count(*) AS y_axis_1 {F} WHERE {ALERT} AND alert_severity = 1", 48),
    metric("Signatures", f"SELECT count(DISTINCT alert_signature_id) AS y_axis_1 {F} WHERE {ALERT}", 96),
    metric("Hosts involved",
           f"SELECT count(DISTINCT CASE WHEN {SRC_INT} THEN src_ip ELSE dest_ip END) AS y_axis_1 {F} WHERE {ALERT}",
           144, description="Distinct local hosts in alerts"),
    timeseries("Alerts by severity", "stacked", "count(*)", ALERT,
               "concat('sev ', CAST(alert_severity AS VARCHAR))", "Severity", layout=(0, 12, 128, 26)),
    donut("Alerts by category",
          f"""SELECT alert_category AS x_axis_1, count(*) AS y_axis_1
              {F} WHERE {ALERT} GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 12""",
          "Category", "Alerts", layout=(128, 12, 64, 26)),
    table("Top signatures",
          f"""SELECT alert_severity AS x_axis_1, alert_signature AS x_axis_2, alert_category AS x_axis_3,
                     count(*) AS y_axis_1, count(DISTINCT src_ip) AS y_axis_2,
                     count(DISTINCT dest_ip) AS y_axis_3, max({TS}) AS y_axis_4
              {F} WHERE {ALERT}
              GROUP BY x_axis_1, x_axis_2, x_axis_3 ORDER BY x_axis_1 ASC, y_axis_1 DESC LIMIT 200""",
          x=[("x_axis_1", "Sev"), ("x_axis_2", "Signature"), ("x_axis_3", "Category")],
          y=[("y_axis_1", "Alerts"), ("y_axis_2", "Sources"), ("y_axis_3", "Destinations"),
             ("y_axis_4", "Last seen")],
          layout=(0, 38, 192, 36),
          description="Noisy signature? Add its SID to services.suricata.disabledRules"),
    table("Latest alerts",
          f"""SELECT {TS} AS x_axis_1, alert_severity AS x_axis_2, alert_signature AS x_axis_3,
                     src_ip AS x_axis_4, src_port AS x_axis_5, dest_ip AS x_axis_6, dest_port AS x_axis_7,
                     app_proto AS x_axis_8, alert_signature_id AS x_axis_9, community_id AS x_axis_10
              {F} WHERE {ALERT} ORDER BY _timestamp DESC LIMIT 500""",
          x=[("x_axis_1", "Time"), ("x_axis_2", "Sev"), ("x_axis_3", "Signature"),
             ("x_axis_4", "Source"), ("x_axis_5", "Src port"), ("x_axis_6", "Destination"),
             ("x_axis_7", "Dst port"), ("x_axis_8", "App"), ("x_axis_9", "SID"),
             ("x_axis_10", "Community ID")],
          y=[], layout=(0, 74, 192, 40),
          description="Search the community ID in the logs view to get every event of that connection"),
    hbar("Top alerting sources",
         f"""SELECT src_ip AS x_axis_1, count(*) AS y_axis_1
             {F} WHERE {ALERT} GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 15""",
         "Source", "Alerts", layout=(0, 114, 96, 30)),
    hbar("Top alerting destinations",
         f"""SELECT dest_ip AS x_axis_1, count(*) AS y_axis_1
             {F} WHERE {ALERT} GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 15""",
         "Destination", "Alerts", layout=(96, 114, 96, 30)),
]

SCAN_SQL = f"""SELECT src_ip AS x_axis_1, count(DISTINCT dest_port) AS y_axis_1,
                      count(DISTINCT dest_ip) AS y_axis_2, count(*) AS y_axis_3,
                      sum(CASE WHEN proto = 'TCP' AND flow_pkts_toclient = 0 THEN 1 ELSE 0 END) AS y_axis_4
               {F} WHERE {FLOW} AND {NOT_NOISE} AND {NOT_LAN}
               GROUP BY x_axis_1
               HAVING count(DISTINCT dest_port) > 20 OR count(DISTINCT dest_ip) > 30
               ORDER BY y_axis_1 DESC LIMIT 100"""

sec_hunting = [
    table("Port scan / sweep candidates", SCAN_SQL,
          x=[("x_axis_1", "Source")],
          y=[("y_axis_1", "Distinct ports"), ("y_axis_2", "Distinct hosts"), ("y_axis_3", "Flows"),
             ("y_axis_4", "Unanswered TCP")],
          layout=(0, 0, 96, 34),
          description="Sources touching many ports (vertical scan) or many hosts (horizontal sweep)"),
    table("Unanswered TCP connections",
          f"""SELECT src_ip AS x_axis_1, dest_ip AS x_axis_2, dest_port AS x_axis_3, count(*) AS y_axis_1
              {F} WHERE {FLOW} AND proto = 'TCP' AND flow_pkts_toclient = 0
              GROUP BY x_axis_1, x_axis_2, x_axis_3 ORDER BY y_axis_1 DESC LIMIT 200""",
          x=[("x_axis_1", "Source"), ("x_axis_2", "Destination"), ("x_axis_3", "Port")],
          y=[("y_axis_1", "Flows")], layout=(96, 0, 96, 34),
          description="The other side never answered: filtered ports, dead services or scans"),
    table("Large uploads to the internet",
          f"""SELECT src_ip AS x_axis_1, dest_ip AS x_axis_2, dest_port AS x_axis_3,
                     sum(flow_bytes_toserver) AS y_axis_1, count(*) AS y_axis_2
              {F} WHERE {FLOW} AND {EGRESS}
              GROUP BY x_axis_1, x_axis_2, x_axis_3 HAVING sum(flow_bytes_toserver) > 50000000
              ORDER BY y_axis_1 DESC LIMIT 100""",
          x=[("x_axis_1", "Local host"), ("x_axis_2", "Destination"), ("x_axis_3", "Port")],
          y=[("y_axis_1", "Bytes sent"), ("y_axis_2", "Flows")], layout=(0, 34, 96, 32), unit="bytes",
          description="More than 50 MB sent to one public address in the time range"),
    table("Unusual outbound ports",
          f"""SELECT src_ip AS x_axis_1, proto AS x_axis_2, dest_port AS x_axis_3, app_proto AS x_axis_4,
                     count(DISTINCT dest_ip) AS y_axis_1, count(*) AS y_axis_2
              {F} WHERE {FLOW} AND {EGRESS} AND dest_port NOT IN ({COMMON_PORTS})
              GROUP BY x_axis_1, x_axis_2, x_axis_3, x_axis_4 ORDER BY y_axis_2 DESC LIMIT 200""",
          x=[("x_axis_1", "Local host"), ("x_axis_2", "Proto"), ("x_axis_3", "Port"), ("x_axis_4", "App")],
          y=[("y_axis_1", "Destinations"), ("y_axis_2", "Flows")], layout=(96, 34, 96, 32),
          description="Extend COMMON_PORTS in generate.py with what is normal for you"),
    table("Beaconing candidates",
          f"""SELECT src_ip AS x_axis_1, dest_ip AS x_axis_2, dest_port AS x_axis_3,
                     count(*) AS y_axis_1, count(DISTINCT date_trunc('hour', {TS})) AS y_axis_2,
                     avg({BYTES}) AS y_axis_3
              {F} WHERE {FLOW} AND {EGRESS}
              GROUP BY x_axis_1, x_axis_2, x_axis_3
              HAVING count(*) >= 24 AND avg({BYTES}) < 20000
                 AND count(DISTINCT date_trunc('hour', {TS})) >= 6
              ORDER BY y_axis_2 DESC, y_axis_1 DESC LIMIT 100""",
          x=[("x_axis_1", "Local host"), ("x_axis_2", "Destination"), ("x_axis_3", "Port")],
          y=[("y_axis_1", "Flows"), ("y_axis_2", "Active hours"), ("y_axis_3", "Avg bytes/flow")],
          layout=(0, 66, 96, 32),
          description="Many small, regular connections to one endpoint. Use 24h+. Expect NTP and update checks"),
    table("DNS bypassing adguard",
          f"""SELECT src_ip AS x_axis_1, dest_ip AS x_axis_2, dest_port AS x_axis_3, count(*) AS y_axis_1
              {F} WHERE {FLOW} AND (app_proto = 'dns' OR dest_port IN (53, 853))
                AND dest_ip NOT IN ({DNS_LIST}) AND src_ip NOT IN ({DNS_LIST}) AND {SRC_INT}
              GROUP BY x_axis_1, x_axis_2, x_axis_3 ORDER BY y_axis_1 DESC LIMIT 100""",
          x=[("x_axis_1", "Client"), ("x_axis_2", "Resolver"), ("x_axis_3", "Port")],
          y=[("y_axis_1", "Flows")], layout=(96, 66, 96, 32),
          description="Clients resolving through something other than adguard (adguard's own upstream traffic is excluded)"),
    table("Suspicious domain names",
          f"""SELECT dns_rrname AS x_axis_1, src_ip AS x_axis_2, length(dns_rrname) AS y_axis_1, count(*) AS y_axis_2
              {F} WHERE {DNS_REQ}
                AND (length(dns_rrname) > 60 OR regexp_like(dns_rrname, '[a-z0-9]{{25,}}'))
              GROUP BY x_axis_1, x_axis_2 ORDER BY y_axis_1 DESC LIMIT 200""",
          x=[("x_axis_1", "Domain"), ("x_axis_2", "Client")], y=[("y_axis_1", "Length"), ("y_axis_2", "Queries")],
          layout=(0, 98, 96, 32),
          description="Very long names or long random-looking labels: DNS tunnelling, DGAs (and CDNs)"),
    table("Legacy TLS",
          f"""SELECT src_ip AS x_axis_1, dest_ip AS x_axis_2, tls_sni AS x_axis_3, tls_version AS x_axis_4,
                     count(*) AS y_axis_1
              {F} WHERE event_type = 'tls' AND tls_version IN ('SSLv2', 'SSLv3', 'TLS 1.0', 'TLS 1.1')
              GROUP BY x_axis_1, x_axis_2, x_axis_3, x_axis_4 ORDER BY y_axis_1 DESC LIMIT 100""",
          x=[("x_axis_1", "Client"), ("x_axis_2", "Server"), ("x_axis_3", "SNI"), ("x_axis_4", "Version")],
          y=[("y_axis_1", "Handshakes")], layout=(96, 98, 96, 32)),
    table("Protocol anomalies",
          f"""SELECT anomaly_type AS x_axis_1, anomaly_event AS x_axis_2, app_proto AS x_axis_3,
                     count(*) AS y_axis_1, count(DISTINCT src_ip) AS y_axis_2
              {F} WHERE event_type = 'anomaly'
              GROUP BY x_axis_1, x_axis_2, x_axis_3 ORDER BY y_axis_1 DESC LIMIT 100""",
          x=[("x_axis_1", "Type"), ("x_axis_2", "Event"), ("x_axis_3", "App")],
          y=[("y_axis_1", "Events"), ("y_axis_2", "Sources")], layout=(0, 130, 96, 30),
          description="Malformed or unexpected protocol behaviour detected by the decoders"),
    table("Inbound sources hitting most ports",
          f"""SELECT src_ip AS x_axis_1, count(DISTINCT dest_port) AS y_axis_1, count(*) AS y_axis_2
              {F} WHERE {FLOW} AND {SRC_EXT} AND {DST_INT}
              GROUP BY x_axis_1 ORDER BY y_axis_1 DESC LIMIT 50""",
          x=[("x_axis_1", "Remote IP")], y=[("y_axis_1", "Distinct ports"), ("y_axis_2", "Flows")],
          layout=(96, 130, 96, 30)),
]

STATS = "event_type = 'stats'"
sec_sensor = [
    metric("Kernel drop rate",
           f"""SELECT CASE WHEN max(stats_capture_kernel_packets) > 0
                      THEN 100.0 * max(stats_capture_kernel_drops) / max(stats_capture_kernel_packets)
                      ELSE 0 END AS y_axis_1
               {F} WHERE {STATS}""", 0, unit="percent",
           description="Packets the kernel dropped before suricata saw them, since suricata started"),
    metric("Uptime (h)", f"SELECT max(stats_uptime) / 3600.0 AS y_axis_1 {F} WHERE {STATS}", 48),
    metric("Peak active flows", f"SELECT max(stats_flow_active) AS y_axis_1 {F} WHERE {STATS}", 96),
    metric("Stats events", f"SELECT count(*) AS y_axis_1 {F} WHERE {STATS}", 144,
           description="One per minute when the sensor is healthy"),
    timeseries("Dropped packets (cumulative)", "line",
               "max(stats_capture_kernel_drops)", STATS, layout=(0, 12, 96, 26),
               description="Counters reset when suricata restarts"),
    timeseries("Events per minute", "area-stacked", "count(*)", "", "event_type", "Type",
               layout=(96, 12, 96, 26), bucket="1 minute"),
    timeseries("Active flows", "line", "max(stats_flow_active)", STATS, layout=(0, 38, 96, 26)),
    timeseries("Memcap / queue problems", "line",
               "max(coalesce(stats_flow_memcap, 0) + coalesce(stats_tcp_ssn_memcap_drop, 0) "
               "+ coalesce(stats_detect_alert_queue_overflow, 0))",
               STATS, layout=(96, 38, 96, 26),
               description="Should stay at 0. If it grows, suricata needs more memory"),
]

security = dashboard(
    "Suricata - security",
    f"IDS alerts, threat hunting heuristics and sensor health from the '{STREAM}' stream",
    [("Alerts", sec_alerts), ("Hunting", sec_hunting), ("Sensor", sec_sensor)],
    period="24h",
)


# ================================================================= alerts
def summary_expr(row_template, cols):
    """Turn "{a} -> {b}" into a SQL concat over the column expressions, so the
    query returns a ready-made one-line description in a "summary" column."""
    exprs = dict((alias, expr) for expr, alias in cols)
    parts = re.split(r"\{(\w+)\}", row_template)
    sql = []
    for i, part in enumerate(parts):
        if i % 2 == 0:
            if part:
                sql.append("'" + part.replace("'", "''") + "'")
        else:
            sql.append(f"coalesce(CAST({exprs[part]} AS VARCHAR), '-')")
    return "concat(" + ", ".join(sql) + ")"


def alert(name, description, cols, rest, period, frequency, silence, row_template, threshold=1):
    """cols: [(sql expression, alias)], rest: everything from FROM on.
    row_template is used both for openobserve's raw payload {rows} and to build
    the "summary" column that the structured template prints per row."""
    select = [f"{expr} AS {alias}" for expr, alias in cols]
    select.insert(0, f"{summary_expr(row_template, cols)} AS summary")
    sql = f"SELECT {', '.join(select)} {rest}"
    return {
        "name": name,
        "org_id": ORG,
        "stream_type": "logs",
        "stream_name": STREAM,
        "is_real_time": False,
        "query_condition": {
            "type": "sql",
            "conditions": None,
            "sql": " ".join(sql.split()),
            "promql": None,
            "promql_condition": None,
            "aggregation": None,
            "vrl_function": None,
            "search_event_type": None,
            "multi_time_range": [],
        },
        "trigger_condition": {
            "period": period,
            "operator": ">=",
            "threshold": threshold,
            "frequency": frequency,
            "frequency_type": "minutes",
            "cron": "",
            "silence": silence,
            "timezone": "UTC",
            "tolerance_in_secs": 0,
            "align_time": True,
        },
        "destinations": [DESTINATION],
        "context_attributes": {},
        "row_template": row_template,
        "row_template_type": "String",
        "description": description,
        "enabled": True,
        "tz_offset": 0,
    }


def sample(col, n=5):
    """comma separated sample of distinct values, for the notification text"""
    return f"array_to_string(array_slice(array_agg(DISTINCT CAST({col} AS VARCHAR)), 1, {n}), ', ')"


# Notification template for a discord webhook destination, importable via
# Management -> Templates -> Import. It is a raw-payload template: openobserve
# substitutes the variables and posts the json as is. {rows} is every result row
# rendered through the alert's row_template; it must sit inside other text, as a
# bare "{rows}" value openobserve inserts a json array. {rows:10} caps it so the
# message stays under discord's 2000 character limit.
TEMPLATE = {
    "name": "suricata-discord",
    "type": "http",
    "body": json.dumps({
        "content": "🚨 **{alert_name}**: {alert_description}\n"
                   "{alert_count} results, {alert_start_time} - {alert_end_time}\n{rows:10}"
    }, ensure_ascii=False),
}

# only columns that exist in the stream: a query naming an unknown column fails
# as a whole, and quic_sni only appears after the first quic event with an sni
NAME = "coalesce(tls_sni, http_hostname, dns_rrname)"
DNS_BYPASS = (f"event_type IN ('flow', 'dns') AND (app_proto = 'dns' OR dest_port IN (53, 853)) "
              f"AND dest_ip NOT IN ({DNS_LIST}) AND src_ip NOT IN ({DNS_LIST}) AND {SRC_INT}")

# every alert is "fire when the query returns at least one row"
alerts = [
    alert("suricata-high-severity", "Severity 1 IDS alert",
          [("alert_signature_id", "sid"), ("alert_signature", "signature"), ("alert_category", "category"),
           ("src_ip", "src_ip"), ("dest_ip", "dest_ip"), ("dest_port", "dest_port"),
           ("coalesce(app_proto, proto)", "app"), (f"max({NAME})", "target"), ("count(*)", "hits"),
           ("min(community_id)", "community_id")],
          f"""{F} WHERE {ALERT} AND alert_severity = 1
              GROUP BY sid, signature, category, src_ip, dest_ip, dest_port, app
              ORDER BY hits DESC LIMIT 20""",
          period=2, frequency=1, silence=30,
          row_template="[{sid}] {signature} ({category}): {src_ip} -> {dest_ip}:{dest_port} {app} {target}, "
                       "{hits}x, {community_id}"),
    alert("suricata-medium-severity", "Severity 2 IDS alerts in the last hour",
          [("alert_signature_id", "sid"), ("alert_signature", "signature"), ("alert_category", "category"),
           ("count(*)", "hits"), (sample("src_ip", 3), "sources"), (sample("dest_ip", 3), "destinations"),
           (sample(NAME, 3), "targets")],
          f"""{F} WHERE {ALERT} AND alert_severity = 2
              GROUP BY sid, signature, category ORDER BY hits DESC LIMIT 25""",
          period=60, frequency=60, silence=0,
          row_template="[{sid}] {signature} ({category}): {hits}x, {sources} -> {destinations} {targets}"),
    alert("suricata-port-scan", "A source touched many ports or hosts within 10 minutes",
          [("src_ip", "src_ip"), ("count(DISTINCT dest_port)", "ports"), ("count(DISTINCT dest_ip)", "hosts"),
           ("sum(CASE WHEN proto = 'TCP' AND flow_pkts_toclient = 0 THEN 1 ELSE 0 END)", "unanswered"),
           (sample("dest_port", 10), "sample_ports"), (sample("dest_ip", 5), "sample_hosts")],
          f"""{F} WHERE {FLOW} AND {NOT_NOISE} AND {NOT_LAN}
              GROUP BY src_ip HAVING count(DISTINCT dest_port) > 50 OR count(DISTINCT dest_ip) > 50
              ORDER BY ports DESC LIMIT 20""",
          period=10, frequency=5, silence=60,
          row_template="{src_ip}: {ports} ports on {hosts} hosts, {unanswered} unanswered. "
                       "Ports {sample_ports}, hosts {sample_hosts}"),
    alert("suricata-large-upload", "More than 500 MB uploaded to a single public address in an hour",
          [("src_ip", "src_ip"), ("dest_ip", "dest_ip"), ("dest_port", "dest_port"),
           ("coalesce(max(app_proto), max(proto))", "app"),
           ("CAST(round(sum(flow_bytes_toserver) / 1000000.0) AS BIGINT)", "mb_out"), ("count(*)", "flows")],
          f"""{F} WHERE {FLOW} AND {EGRESS}
              GROUP BY src_ip, dest_ip, dest_port HAVING sum(flow_bytes_toserver) > 500000000
              ORDER BY mb_out DESC LIMIT 20""",
          period=60, frequency=15, silence=240,
          row_template="{src_ip} -> {dest_ip}:{dest_port} {app}: {mb_out} MB in {flows} flows"),
    alert("suricata-dns-bypass", "A client used a DNS server other than adguard",
          [("src_ip", "src_ip"), ("dest_ip", "dest_ip"), ("dest_port", "dest_port"),
           ("coalesce(max(app_proto), max(proto))", "app"), ("count(*)", "events"),
           (sample("dns_rrname", 5), "names")],
          f"""{F} WHERE {DNS_BYPASS}
              GROUP BY src_ip, dest_ip, dest_port ORDER BY events DESC LIMIT 20""",
          period=15, frequency=15, silence=360,
          row_template="{src_ip} -> {dest_ip}:{dest_port} {app}, {events} events, queried {names}"),
    alert("suricata-new-egress-port",
          "A local host talked to the internet on a port it did not use in the previous 24h",
          [("src_ip", "src_ip"), ("proto", "proto"), ("dest_port", "dest_port"),
           ("coalesce(max(app_proto), '-')", "app"), ("count(*)", "flows"),
           ("count(DISTINCT dest_ip)", "peers"), (sample("dest_ip", 5), "sample_peers"),
           (f"CAST(round(sum({BYTES}) / 1000.0) AS BIGINT)", "kb")],
          f"""{F} WHERE {FLOW} AND {EGRESS} AND dest_port < 32768
              GROUP BY src_ip, proto, dest_port
              HAVING to_timestamp_micros(min(_timestamp)) >= now() - INTERVAL '1 hour'
              ORDER BY flows DESC LIMIT 25""",
          period=1440, frequency=60, silence=0,
          row_template="{src_ip} -> {proto}/{dest_port} {app}: {flows} flows, {kb} kB to {peers} peers "
                       "({sample_peers})"),
    alert("suricata-sensor-silent",
          "No stats events from suricata for 10 minutes: sensor or shipper is down",
          [("count(*)", "stats_events")],
          f"{F} WHERE {STATS} HAVING count(*) = 0",
          period=10, frequency=5, silence=60,
          row_template="{stats_events} stats events in 10 minutes, "
                       "check suricata and suricata-eve-shipper on amd-server"),
    alert("suricata-packet-drops", "Suricata is dropping more than 5% of packets",
          [("max(stats_capture_kernel_drops)", "drops"), ("max(stats_capture_kernel_packets)", "packets"),
           ("round(100.0 * max(stats_capture_kernel_drops) / max(stats_capture_kernel_packets), 1)", "pct")],
          f"""{F} WHERE {STATS}
              HAVING max(stats_capture_kernel_packets) > 0
                 AND 100.0 * max(stats_capture_kernel_drops) / max(stats_capture_kernel_packets) > 5""",
          period=15, frequency=15, silence=240,
          row_template="{pct}% dropped ({drops} of {packets} packets since suricata started)"),
]

out_dir = Path(sys.argv[1])
out_dir.mkdir(parents=True, exist_ok=True)
for name, d in (("suricata-network.json", network), ("suricata-security.json", security),
                ("suricata-alerts.json", alerts), ("suricata-template.json", TEMPLATE)):
    (out_dir / name).write_text(json.dumps(d, indent=2) + "\n")
    print(out_dir / name)
