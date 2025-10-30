{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.adam-site;
in
{
  options.custom.services.adam-site = {
    enable = mkEnableOption "Enables adams website";
  };
  config = lib.mkIf cfg.enable {
    systemd.services.adam-site = {
      description = "Adams Website";
      wants = [ "network-online.target" ];
      after = [
        "network.target"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        if [ ! -d "$STATE_DIRECTORY/data" ]; then
          mkdir -p "$STATE_DIRECTORY/data"
          chmod 700 "$STATE_DIRECTORY/data"
        fi
      '';
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.nodejs_20}/bin/node ${pkgs.adam-site}/server/server.mjs";
        DynamicUser = true;
        StateDirectory = "adam-site";
        WorkingDirectory = "/var/lib/private/adam-site";
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

    };
  };
}
