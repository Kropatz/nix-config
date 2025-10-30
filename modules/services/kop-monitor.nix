{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.kop-monitor;
in
{
  options.custom.services.kop-monitor = {
    enable = mkEnableOption "Enables monitor";
  };
  config = lib.mkIf cfg.enable {
    age.secrets.webhook = {
      file = ../../secrets/webhook.age;
    };
    # service that runs all the time, pkgs.kop-monitor
    systemd.services.kop-monitor = {
      description = "Kop Monitor";
      wants = [ "network-online.target" ];
      after = [
        "network.target"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kop-monitor}/bin/monitor";
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = "5s";
        EnvironmentFile = config.age.secrets.webhook.path;
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
