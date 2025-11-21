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
        User = "kop-pvlog";
        Restart = "on-failure";
        RestartSec = "5s";
        PrivateMounts = mkDefault true;
        PrivateTmp = mkDefault true;
        PrivateUsers = mkDefault true;
        ProtectClock = mkDefault true;
        ProtectControlGroups = mkDefault true;
        ProtectHome = mkDefault true;
        ProtectHostname = mkDefault true;
        ProtectKernelLogs = mkDefault true;
        ProtectKernelModules = mkDefault true;
        ProtectKernelTunables = mkDefault true;
        ProtectSystem = mkDefault "strict";
        # Needs network access
        PrivateNetwork = mkDefault false;
      };

      environment = {
        PORT = "${toString cfg.port}";
        DATA_PATH = "${toString cfg.dataDir}";
      };
    };
  };
}
