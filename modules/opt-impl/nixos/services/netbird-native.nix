{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "netbird-native";
  cfg = config.custom.services.${name};
in
{
  config = lib.mkIf cfg.enable {
    users.users.netbird = {
      uid = config.custom.vars.uids."netbird";
      group = "netbird";
      isSystemUser = true;
      createHome = true;
      home = cfg.dataDir;
    };
    users.groups.netbird = {
      gid = config.custom.vars.gids."netbird";
    };

    systemd.timers.backup-netbird = {
      description = "Periodically backup netbird data";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "5m";
      };
    };

    systemd.services = {
      backup-netbird =
        let
          backupNetbird = pkgs.writeShellScript "backup-netbird" ''
            set -euo pipefail

            DEST="/mnt/backups/netbird"

            mkdir -p "''${DEST}"
            cp -r /etc/netbird "''${DEST}/etc-netbird"
            cp -r /var/lib/netbird "''${DEST}/var-lib-netbird"

            echo "Backup completed: ''${DEST}"
          '';
        in
        {
          description = "Periodically backup netbird data";
          after = [
            "mnt-backups.mount"
          ];
          requires = [
            "mnt-backups.mount"
          ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${backupNetbird}";
            User = "root";
            ReadWritePaths = [ "/mnt/backups" ];
            ReadOnlyPaths = [
              "/etc/netbird"
              "/var/lib/netbird"
            ];
            # Basic hardening
            CapabilityBoundingSet = "";
            NoNewPrivileges = true;
            ProtectSystem = "strict";
            # needs access to /mnt/backups, so we can't use PrivateMounts
            PrivateMounts = false;
            ProtectHome = true;
            PrivateTmp = true;
            # needed
            PrivateUsers = false;
            PrivateDevices = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            RemoveIPC = true; # Remove IPC objects when unit is stopped
            RestrictAddressFamilies = [ "none" ];
            RestrictNamespaces = "yes";
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallFilter = "@system-service";
            SystemCallArchitectures = "native";
            ## Proc filesystem
            ProcSubset = "pid";
            ProtectProc = "invisible";
            PrivateNetwork = true;
          };
        };
      netbird-server = {
        description = "NetBird server daemon";
        wants = [ "network-online.target" ];
        after = [
          "network.target"
          "network-online.target"
        ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.netbird-combined}/bin/netbird-server -c /etc/netbird/config.yaml";
          WorkingDirectory = cfg.dataDir;
          BindPaths = [ "${cfg.dataDir}" ];
          ReadWritePaths = [ "${cfg.dataDir}" ];
          User = "netbird";
          Group = "netbird";
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
        };
      };
    };
  };
}
