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
        User = "kop-fileshare";
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
        UPLOAD_PATH = "${toString cfg.dataDir}";
        BASE_PATH = "${cfg.basePath}";
      };
    };
  };
}
