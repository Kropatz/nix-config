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
  options = {
    custom.services.kop-fileshare = {
      enable = mkEnableOption "Enable the file upload server";
      port = mkOption {
        type = types.int;
        default = 7777;
        description = "Port for the file upload server";
      };
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/file-upload";
        description = "Directory to store uploaded files";
      };
      basePath = mkOption {
        type = types.str;
        default = "/";
        description = "Location under which the file upload server is reachable";
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.kop-fileshare = {
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "kop-fileshare";
    };
    users.groups.kop-fileshare = { };
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
        PrivateMounts = true;
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
        UPLOAD_PATH = "${toString cfg.dataDir}";
        BASE_PATH = "${cfg.basePath}";
      };
    };
  };
}
