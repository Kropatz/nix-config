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

    services.fluent-bit =
      let
        nginxInput = lib.optionalString cfg.enableNginxLogs ''
          # Input for nginx access logs
            - db: ${base}/fluent-bit/fluent-bit-nginx-access.db
              name: tail
              path: /var/log/nginx/access.log
              tag: nginx.access'';
        nginxFilters = lib.optionalString cfg.enableNginxLogs ''
          # Filters for nginx access logs
            - key_name: log
              match: nginx.access
              name: parser
              parser: nginx
              preserve_key: true
              reserve_data: true
            - match: nginx.access
              name: grep
              regex: $code ^[235][0-9][0-9]$
            - exclude: $path ^/signalexchange.SignalExchange/Send$
              match: nginx.access
              name: grep
            - exclude: $path ^/api/actions/runner.v1.RunnerService/FetchTask$
              match: nginx.access
              name: grep
            - exclude: $referer ^https?://grafana\.kopatz\.dev/
              match: nginx.access
              name: grep
            - Rename:
              - log MESSAGE
              - remote ngx_client_ip
              - host ngx_host
              - user ngx_client_user
              - time ngx_time_local
              - method ngx_request_method
              - path ngx_request_uri
              - code ngx_status
              - size ngx_body_bytes_sent
              - referer ngx_http_referer
              - agent ngx_http_user_agent
              match: nginx.access
              name: modify'';
        systemdInput = ''
          # Input for systemd logs
            - db: ${base}/fluent-bit/fluent-bit-systemd.db
              name: systemd
              read_from_tail: true
              tag: systemd.*'';
        systemdFilters = ''
          # Filters for systemd logs
            - Copy:
              - PRIORITY severity
              Remove:
              - _MACHINE_ID
              - _PID
              - _UID
              - _GID
              - _CAP_EFFECTIVE
              - _SYSTEMD_INVOCATION_ID
              - _SYSTEMD_CGROUP
              - _SYSTEMD_SLICE
              - _SYSTEMD_SESSION
              - _SYSTEMD_OWNER_UID
              - _SYSTEMD_OWNER_GID
              - _SYSTEMD_USER_UNIT
              - _SYSTEMD_USER_SLICE
              - _SYSTEMD_USER_SESSION
              - CONTAINER_LOG_EPOCH
              - CONTAINER_LOG_ORDINAL
              - CONTAINER_ID_FULL
              Rename:
              - _SYSTEMD_UNIT unit
              - _HOSTNAME hostname
              match: systemd.*
              name: modify'';
      in
      {
        enable = true;
        configurationFile = pkgs.writeText "fluent-bit.yml" ''
          %YAML 1.1
          ---
          pipeline:
            filters:
            ${systemdFilters}
            ${nginxFilters}
            inputs:
            ${systemdInput}
            ${nginxInput}
            outputs:
            - host: 192.168.0.10
              match: '*'
              name: loki
            - compress: gzip
              host: 192.168.0.13
              http_passwd: o2oi_qcZ6tIq4m0P0l6Eh1exEOwa6WY7ojAej
              http_user: root@kopatz.dev
              json_date_format: iso8601
              json_date_key: _timestamp
              log_level: warn
              log_response_payload: false
              match: '*'
              name: http
              port: 5080
              tls: 'off'
              uri: /api/default/default/_json
          service:
            grace: 30
            parsers_file: 
              ${config.services.fluent-bit.package}/etc/fluent-bit/parsers.conf
        '';
      };
  };
}
