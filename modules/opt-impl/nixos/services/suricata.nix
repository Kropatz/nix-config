{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.services.suricata;
  suricataCfg = config.services.suricata.settings;
  # eve events go straight from suricata into this socket, nothing is written to disk
  socketDir = "/run/suricata-eve";
  socket = "${socketDir}/eve.sock";
  # anything suricata still insists on writing as a file ends up in RAM
  logDir = "/run/suricata-log";
  # rules + suricata-update cache, re-downloaded after every boot
  stateDir = "/var/lib/suricata";

  # openobserve stores arrays as json strings, so pull the first dns query and
  # all answers out into plain fields. stats events have hundreds of counters,
  # only keep the ones that are worth graphing.
  eveFilter = pkgs.writeText "suricata-eve-filter.lua" ''
    local function pick(t, keys)
      if type(t) ~= "table" then return nil end
      local out = {}
      for _, k in ipairs(keys) do out[k] = t[k] end
      return out
    end

    function eve(tag, ts, r)
      local dns = r["dns"]
      if type(dns) == "table" then
        local q = dns["queries"]
        if type(q) == "table" and type(q[1]) == "table" then
          r["dns_rrname"] = q[1]["rrname"]
          r["dns_rrtype"] = q[1]["rrtype"]
        end
        local a = dns["answers"]
        if type(a) == "table" then
          local rdata = {}
          for _, ans in ipairs(a) do
            if type(ans) == "table" and ans["rdata"] ~= nil then
              table.insert(rdata, tostring(ans["rdata"]))
            end
          end
          if #rdata > 0 then r["dns_answer"] = table.concat(rdata, ",") end
        end
      end

      local st = r["stats"]
      if r["event_type"] == "stats" and type(st) == "table" then
        r["stats"] = {
          uptime = st["uptime"],
          capture = pick(st["capture"], { "kernel_packets", "kernel_drops", "kernel_ifdrops", "errors" }),
          decoder = pick(st["decoder"], { "pkts", "bytes", "invalid" }),
          detect = pick(st["detect"], { "alert", "alert_queue_overflow", "alerts_suppressed" }),
          flow = pick(st["flow"], { "total", "active", "memcap" }),
          tcp = pick(st["tcp"], { "sessions", "ssn_memcap_drop", "reassembly_gap" }),
        }
      end
      return 2, ts, r
    end
  '';

  shipperConfig = pkgs.writeText "suricata-eve-shipper.yml" ''
    service:
      flush: 5
      log_level: warn
      http_server: off
    parsers:
      - name: suricata_eve
        format: json
        time_key: timestamp
        time_format: "%Y-%m-%dT%H:%M:%S.%L%z"
        time_keep: on
    pipeline:
      inputs:
        - name: syslog
          mode: unix_tcp
          path: ${socket}
          unix_perm: "0660"
          parser: suricata_eve
          buffer_chunk_size: 64k
          buffer_max_size: 4M
          mem_buf_limit: 128M
          tag: suricata
      filters:
        - name: lua
          match: '*'
          script: ${eveFilter}
          call: eve
      outputs:
        - name: http
          match: '*'
          host: ${cfg.openobserveHost}
          port: 5080
          uri: /api/default/${cfg.stream}/_json
          format: json
          json_date_key: _timestamp
          json_date_format: iso8601
          compress: gzip
          http_user: root@kopatz.dev
          http_passwd: o2oi_qcZ6tIq4m0P0l6Eh1exEOwa6WY7ojAej
          tls: off
          retry_limit: 10
  '';
in
{
  config = lib.mkIf cfg.enable {
    fileSystems.${stateDir} = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "size=512M"
        "mode=0755"
      ];
    };

    services.suricata = {
      enable = true;
      # rules are gone after a reboot, so reload once suricata-update fetched them
      reloadOnRulesetUpdate = true;
      settings = {
        default-log-dir = logDir;
        # industrial protocols are off by default in suricata 8. Saying so
        # explicitly makes suricata-update disable their rules, otherwise those
        # rules fail to parse and suricata -T refuses to start.
        app-layer.protocols = {
          modbus.enabled = "no";
          dnp3.enabled = "no";
        };
        af-packet = map (iface: {
          interface = iface;
          cluster-id = 99;
          cluster-type = "cluster_flow";
          defrag = "yes";
        }) cfg.interfaces;
        # console only -> journal, no suricata.log. suricata reads "enabled",
        # the module's "enable" is ignored and outputs default to on.
        logging.outputs = {
          console.enable = true;
          file = {
            enable = false;
            enabled = "no";
          };
        };
        stats.interval = "60";
        outputs = [
          {
            eve-log = {
              enabled = true;
              filetype = "unix_stream";
              filename = socket;
              community-id = true;
              types = [
                {
                  alert = {
                    payload-printable = "yes";
                    tagged-packets = "yes";
                  };
                }
                { anomaly.enabled = "yes"; }
                { http.extended = "yes"; }
                { dns.enabled = "yes"; }
                { tls.extended = "yes"; }
                { files.force-magic = "no"; }
                { smtp.enabled = "yes"; }
                { ssh.enabled = "yes"; }
                { dhcp.enabled = "yes"; }
                { quic.enabled = "yes"; }
                { mqtt.enabled = "yes"; }
                { flow.enabled = "yes"; }
                { stats.totals = "yes"; }
              ];
            };
          }
        ];
      };
    };

    users.users.suricata-shipper = {
      isSystemUser = true;
      group = suricataCfg.run-as.group;
    };

    systemd.services.suricata = {
      wants = [ "suricata-eve-shipper.service" ];
      after = [ "suricata-eve-shipper.service" ];
      unitConfig.RequiresMountsFor = [ stateDir ];
    };

    systemd.services.suricata-update = {
      unitConfig.RequiresMountsFor = [ stateDir ];
      serviceConfig = {
        # tmpfs is empty after boot, tmpfiles may have run before it was mounted
        ExecStartPre = "+${pkgs.coreutils}/bin/install -d -o ${suricataCfg.run-as.user} -g ${suricataCfg.run-as.group} -m 0755 ${stateDir} ${suricataCfg.default-rule-path}";
        Restart = "on-failure";
        RestartSec = "2min";
      };
    };

    systemd.services.suricata-eve-shipper = {
      description = "Ship suricata eve events to openobserve";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.fluent-bit}/bin/fluent-bit -c ${shipperConfig}";
        User = "suricata-shipper";
        Group = suricataCfg.run-as.group;
        RuntimeDirectory = baseNameOf socketDir;
        RuntimeDirectoryMode = "0750";
        Restart = "on-failure";
        RestartSec = "5s";
        # Security hardening
        UMask = "007";
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        PrivateMounts = true;
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = "yes";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallFilter = "@system-service";
        SystemCallArchitectures = "native";
        ProcSubset = "pid";
        ProtectProc = "invisible";
        PrivateNetwork = false;
        # End Security hardening
      };
    };
  };
}
