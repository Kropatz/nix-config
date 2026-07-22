{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.ente;
in
{
  config = lib.mkIf cfg.enable {
  systemd.services.ente-backup = {
    description = "Ente backup";
    path = with pkgs; [ gnutar gzip coreutils sqlite ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "${pkgs.bash}/bin/bash /mnt/ente/backup.sh";
    };
  };

  systemd.timers.ente-backup = {
    description = "Daily Ente backup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 23:00:00";
      Persistent = true;
    };
  };

    users.users.ente = {
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      uid = config.custom.vars.uids.ente;
      group = "ente";
    };
    users.groups.ente = {
      gid = config.custom.vars.gids.ente;
    };

    age.secrets.ente-config = {
      file = ../../../../secrets/ente-config.age;
      owner = "ente";
      group = "ente";
    };

    systemd.services.ente = {
      description = "ente backend";
      wants = [ "network-online.target" ];
      after = [
        "network.target"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.ente-backend}/bin/ente";
        WorkingDirectory = cfg.dataDir;
        BindPaths = [ "${cfg.dataDir}" ];
        ReadWritePaths = [ "${cfg.dataDir}" ];
        User = "ente";
        Group = "ente";
        Restart = "on-failure";
        RestartSec = "5s";
        # Security hardening
        InaccessiblePaths = config.custom.services.hardening.dataMounts;
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
        CONFIG_PATH = "${config.age.secrets.ente-config.path}";
        PORT = "8081";
      };
    };
  };
}
