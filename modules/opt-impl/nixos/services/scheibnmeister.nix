{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.scheibnmeister;
in
{
  config = mkIf cfg.enable {
    systemd.services = {
      scheibnmeister-lavalink = {
        description = "Scheibnmeister lavalink";
        wants = [ "network-online.target" ];
        after = [
          "network.target"
          "network-online.target"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig =
          let
            lavalinkDir = "${cfg.dataDir}/lavalink";
          in
          {
            ExecStart = "${pkgs.jdk17}/bin/java -jar Lavalink.jar";
            WorkingDirectory = lavalinkDir;
            BindPaths = [ "${lavalinkDir}" "/home/anon/.pub-cache" ];
            ReadWritePaths = [ "${lavalinkDir}" "/home/anon/.pub-cache" ];
            User = "anon";
            Group = "users";
            Restart = "on-failure";
            RestartSec = "5s";
            # Security hardening
            UMask = "077";
            CapabilityBoundingSet = "";
            InaccessiblePaths = config.custom.services.hardening.dataMounts;
            NoNewPrivileges = true;
            ProtectSystem = "strict";
            PrivateMounts = true;
            # ProtectHome = true;
            PrivateTmp = true;
            # PrivateUsers = true;
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
          };
      };
      scheibnmeister = {
        description = "Scheibnmeister";
        wants = [ "network-online.target" ];
        after = [
          "network.target"
          "network-online.target"
          "scheibnmeister-lavalink.service"
        ];
        requires = [ "scheibnmeister-lavalink.service" ];
        wantedBy = [ "multi-user.target" ];
        # nyxx_commands:compile spawns `dart compile exe` via PATH lookup
        path = with pkgs; [ dart yt-dlp ];
        script = ''
          ${pkgs.dart}/bin/dart run nyxx_commands:compile bin/scheibnkleister.dart -o scheibnkleister.g.dart
          ./scheibnkleister.g.exe
        '';

        serviceConfig = {
          WorkingDirectory = cfg.dataDir;
          BindPaths = [ "${cfg.dataDir}" ];
          ReadWritePaths = [ "${cfg.dataDir}" ];
          User = "anon";
          Group = "users";
          Restart = "on-failure";
          RestartSec = "5s";
          # Security hardening
          UMask = "077";
          CapabilityBoundingSet = "";
          InaccessiblePaths = config.custom.services.hardening.dataMounts;
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          PrivateMounts = true;
          # ProtectHome = true;
          PrivateTmp = true;
          # PrivateUsers = true;
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
