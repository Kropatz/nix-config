{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.kop-fileshare;
in
{

  config = mkIf cfg.enable {
    users.users.kop-fileshare = {
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      uid = 2000;
      group = "kop-fileshare";
    };
    users.groups.kop-fileshare = {
      gid = 2000;
    };
    systemd.services.kop-fileshare = {
      description = "File Upload Server";
      wants = [ "network-online.target" ];
      after = [
        "network.target"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.kop-fileshare}/bin/kop-fileshare";
        WorkingDirectory = cfg.dataDir;
        BindPaths = [ "${cfg.dataDir}" ];
        ReadWritePaths = [ "${cfg.dataDir}" ];
        User = "kop-fileshare";
        Group = "kop-fileshare";
        Restart = "on-failure";
        RestartSec = "5s";
        # Security hardening
        UMask = "077";
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        # PrivateMounts = true;
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
        LISTEN_ADDR = "${cfg.listenAddr}";
        UPLOAD_PATH = "${toString cfg.dataDir}";
        BASE_PATH = "${cfg.basePath}";
      };
    };
  };
}
