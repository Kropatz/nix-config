{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  cfg = config.custom.services.grafana-log-agent;
  base = "/mnt/tmpfs";
  dirOwner = if config.services.grafana.enable then "grafana" else "fluent-bit";
in
{
  config = lib.mkIf cfg.enable {
    fileSystems = {
      "${base}" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "size=2G"
          "mode=1777"
        ];
      };
    };
    systemd.tmpfiles.rules = [
      "d ${base} 0755 ${dirOwner} ${dirOwner} -"
      "d ${base}/fluent-bit 0750 fluent-bit ${dirOwner} -"
    ];

    users.users.fluent-bit = {
      isSystemUser = true;
      group = "fluent-bit";
      extraGroups = lib.optionals cfg.enableNginxLogs [ "nginx" ];
    };
    users.groups.fluent-bit = { };
    systemd.services.fluent-bit.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = lib.mkForce "fluent-bit";
      Group = lib.mkForce "fluent-bit";
      WorkingDirectory = lib.mkForce "${base}/fluent-bit";
      ReadWritePaths = lib.mkForce [ "${base}/fluent-bit" ];
      # Security hardening
      UMask = "077";
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      PrivateMounts = true;
      ProtectHome = true;
      PrivateTmp = true;
      PrivateUsers = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      # ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RemoveIPC = true; # Remove IPC objects when unit is stopped
      RestrictNamespaces = "yes";
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallFilter = "@system-service";
      SystemCallArchitectures = "native";
      ## Proc filesystem
      ProcSubset = "pid";
      ProtectProc = "invisible";
      # Needs network access
      PrivateNetwork = false;
      # End Security hardening
    };

    services.fluent-bit = {
      enable = true;
      settings = {
        pipeline = {
          inputs = [
            {
              name = "systemd";
              tag = "systemd.*";
              db = "${base}/fluent-bit/fluent-bit-systemd.db";
              read_from_tail = true;
            }
          ]
          ++ lib.optionals cfg.enableNginxLogs [
            {
              name = "tail";
              tag = "nginx.access";
              path = "/var/log/nginx/access.log";
              db = "${base}/fluent-bit/fluent-bit-nginx-access.db";
            }

          ];
          filters = [
            {
              name = "modify";
              match = "systemd.*";
              Rename = [
                "_SYSTEMD_UNIT unit"
                "_HOSTNAME hostname"
              ];
              # openobserve derives the row colour from severity (0-7 = syslog levels), it doesn't know PRIORITY
              Copy = [ "PRIORITY severity" ];
              Remove = [
                "_MACHINE_ID"
                "_PID"
                "_UID"
                "_GID"
                "_CAP_EFFECTIVE"
                "_SYSTEMD_INVOCATION_ID"
                "_SYSTEMD_CGROUP"
                "_SYSTEMD_SLICE"
                "_SYSTEMD_SESSION"
                "_SYSTEMD_OWNER_UID"
                "_SYSTEMD_OWNER_GID"
                "_SYSTEMD_USER_UNIT"
                "_SYSTEMD_USER_SLICE"
                "_SYSTEMD_USER_SESSION"
                "CONTAINER_LOG_EPOCH"
                "CONTAINER_LOG_ORDINAL"
                "CONTAINER_ID_FULL"
              ];
            }
          ]
          ++ lib.optionals cfg.enableNginxLogs [
            {
              # parse in a filter instead of the tail input so the raw line is kept
              # https://github.com/fluent/fluent-bit/blob/master/conf/parsers.conf
              name = "parser";
              match = "nginx.access";
              key_name = "log";
              parser = "nginx";
              reserve_data = true;
              preserve_key = true;
            }
            {
              name = "grep";
              match = "nginx.access";
              regex = "$code ^[235][0-9][0-9]$";
            }
            {
              name = "grep";
              match = "nginx.access";
              exclude = "$path ^/signalexchange.SignalExchange/Send$";
            }
            {
              name = "grep";
              match = "nginx.access";
              exclude = "$path ^/api/actions/runner.v1.RunnerService/FetchTask$";
            }
            {
              # no host in the combined format, requests from the grafana ui carry it as referer
              name = "grep";
              match = "nginx.access";
              exclude = "$referer ^https?://grafana\\.kopatz\\.dev/";
            }
            {
              name = "modify";
              match = "nginx.access";
              # Regex ^(?<remote>[^ ]*) (?<host>[^ ]*) (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")
              Rename = [
                "log MESSAGE"
                "remote ngx_client_ip"
                "host ngx_host"
                "user ngx_client_user"
                "time ngx_time_local"
                "method ngx_request_method"
                "path ngx_request_uri"
                "code ngx_status"
                "size ngx_body_bytes_sent"
                "referer ngx_http_referer"
                "agent ngx_http_user_agent"
              ];
            }
          ];
          outputs = [
            {
              name = "loki";
              match = "*";
              host = config.custom.vars.serverIp;
            }
            {
              name = "http";
              match = "*";
              uri= "/api/default/default/_json";
              tls = "off";
              compress = "gzip";
              json_date_key = "_timestamp";
              json_date_format = "iso8601";
              http_user = "root@kopatz.dev";
              http_passwd = "o2oi_4SYuvexBd7Ne2Opglns7WWWCo8FgmdAc"; # dont care about the ingestion token being in git
              host = config.custom.vars.zelIp;
              port = 5080;
              log_response_payload = false;
              log_level = "warn";
            }
          ];
        };
        service = {
          grace = 30;
          parsers_file = "${config.services.fluent-bit.package}/etc/fluent-bit/parsers.conf";
        };
      };
    };
  };
}
