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
  options = {
    custom.services.kop-pvlog = {
      enable = mkEnableOption "Enable the fronius data logger";
      port = mkOption {
        type = types.int;
        default = 7788;
        description = "Port for the fronius data logger";
      };
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/pvlog";
        description = "Directory to store the data";
      };
      basePath = mkOption {
        type = types.str;
        default = "/";
        description = "Location under which the data logger is reachable";
      };
      fqdn = mkOption {
        type = types.str;
        default = "pvlog.home.arpa";
        description = "FQDN under which the data logger is reachable";
      };
      useStepCa = mkOption {
        type = types.bool;
        default = true;
        description = "Use step-ca for ACME certificates";
      };
    };
  };

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
      enableACME = true;
      quic = true;
      http3 = true;
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
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictNamespaces = "yes";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallFilter="@system-service";
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
