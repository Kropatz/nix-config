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
        #ProcSubset = "pid"; needed by monitor
        #ProtectProc = "invisible";
        # Needs network access
        PrivateNetwork = false;
        # End Security hardening
      };

    };
  };
}
