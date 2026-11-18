{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.kop-service-dashboard;
in
{

  config = mkIf cfg.enable {
    users.users.kop-service-dashboard = {
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "kop-service-dashboard";
    };
    users.groups.kop-service-dashboard = { };

    services.nginx.virtualHosts."${cfg.fqdn}" = {
      forceSSL = true;
      useACMEHost = "kopatz.dev";
      # quic = true;
      # http3 = true;
      http2 = config.custom.vars.nginx.useHttp2;
      extraConfig = ''
        if ($reject_br) { return 415; }
        ${config.custom.vars.nginx.allowOnlyInternalIps}
      '';
      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
      locations."/".extraConfig = ''
        gzip_types application/octet-stream application/json text/css text/javascript application/javascript;
        more_clear_headers 'x-frame-options';
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
        add_header Access-Control-Allow-Headers "Authorization, Origin, X-Requested-With, Content-Type, Accept";
      '';
    };
    systemd.services.kop-service-dashboard = {
      description = "Service dashboard";
      wants = [ "network-online.target" ];
      after = [
        "network.target"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.kop-service-dashboard}/bin/kop-service-dashboard -addr :${toString cfg.port}";
        WorkingDirectory = cfg.dataDir;
        BindPaths = [ "${cfg.dataDir}" ];
        ReadWritePaths = [ "${cfg.dataDir}" ];
        User = "kop-service-dashboard";
        Group = "kop-service-dashboard";
        Restart = "on-failure";
        RestartSec = "5s";
        # Security hardening
        InaccessiblePaths = (lib.remove "-/data" config.custom.services.hardening.dataMounts) ++ [ "-/data/synced"];
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
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RemoveIPC = true; # Remove IPC objects when unit is stopped
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
        ## Proc filesystem
        ProcSubset = "pid";
        ProtectProc = "invisible";
        # Needs network access
        PrivateNetwork = false;
        # End Security hardening
      };
    };
  };
}
