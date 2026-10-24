{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "openobserve";
  cfg = config.custom.services.${name};
in
{
  config = lib.mkIf cfg.enable {
    users.users.openobserve = {
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "openobserve";
    };
    users.groups.openobserve = { };

    age.secrets.openobserve-env = {
      file = ../../../../secrets/openobserve-env.age;
      owner = "openobserve";
      group = "openobserve";
    };
    networking.firewall.allowedTCPPorts = [ 5080 ];

    systemd.services.openobserve = {
      description = "OpenObserve service";
      wants = [ "network-online.target" ];
      after = [
        "network.target"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ config.age.secrets.openobserve-env.path ];

      serviceConfig = {
        ExecStart = "${pkgs.openobserve}/bin/openobserve";
        WorkingDirectory = cfg.dataDir;
        BindPaths = [ "${cfg.dataDir}" ];
        ReadWritePaths = [ "${cfg.dataDir}" ];
        EnvironmentFile = config.age.secrets.openobserve-env.path;
        User = "openobserve";
        Group = "openobserve";
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
        Environment = [
          "ZO_MEMORY_CACHE_MAX_SIZE=512" # MB
          "ZO_MEM_TABLE_MAX_SIZE=512" # MB
        ];
      };
    };
  };
}
