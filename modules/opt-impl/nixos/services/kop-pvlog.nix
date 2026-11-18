{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.kop-pvlog;
in
{

  config = mkIf cfg.enable {
    users.users.kop-pvlog = {
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "kop-pvlog";
    };
    users.groups.kop-pvlog = { };
    security.acme.certs."${cfg.fqdn}" = lib.mkIf cfg.useStepCa {
      server = "https://127.0.0.1:8443/acme/kop-acme/directory";
    };
    services.nginx.virtualHosts."${cfg.fqdn}" = {
      forceSSL = true;
      enableACME = mkIf cfg.useStepCa true;
      useACMEHost = mkIf (!cfg.useStepCa) "kopatz.dev";
      # quic = true;
      # http3 = true;
      http2 = config.custom.vars.nginx.useHttp2;
      extraConfig = ''
        if ($reject_br) { return 415; }
        ${config.custom.vars.nginx.allowOnlyInternalIps}
      '';
      locations."/".proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
      locations."/".extraConfig = ''
        gzip_types application/octet-stream application/json text/css text/javascript application/javascript;
        more_clear_headers 'x-frame-options';
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
        add_header Access-Control-Allow-Headers "Authorization, Origin, X-Requested-With, Content-Type, Accept";
      '';
    };
    systemd.services.kop-pvlog = {
      description = "Fronius data logger";
      wants = [ "network-online.target" ];
      after = [
        "network.target"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.kop-pvlog}/bin/kop-pvlog";
        WorkingDirectory = cfg.dataDir;
        BindPaths = [ "${cfg.dataDir}" ];
        ReadWritePaths = [ "${cfg.dataDir}" ];
        User = "kop-pvlog";
        Group = "kop-pvlog";
        Restart = "on-failure";
        RestartSec = "5s";
        # Security hardening
        UMask = "077";
        CapabilityBoundingSet = "";
        InaccessiblePaths = (lib.remove "-/data" config.custom.services.hardening.dataMounts) ++ [
          "-/data/synced"
        ];
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

      environment = {
        PORT = "${toString cfg.port}";
        DATA_PATH = "${toString cfg.dataDir}";
      };
    };
  };
}
