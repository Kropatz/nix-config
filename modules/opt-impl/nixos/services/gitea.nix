{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.gitea;
in
{
  config = lib.mkIf cfg.enable {
    age.secrets.git-mail-pw = {
      file = ../../../../secrets/git-mail-pw.age;
      owner = "gitea";
    };
    users.users.gitea = {
      isSystemUser = true;
      group = "gitea";
      createHome = true;
      uid = config.custom.vars.uids.gitea;
      home = cfg.dataDir;
    };

    users.groups.gitea = {
      gid = config.custom.vars.uids.gitea;
    };
    # Initial setup requires creating an admin user with DISABLE_REGISTRATION set to false
    # https://docs.gitea.com/next/administration/config-cheat-sheet
    services.gitea = {
      enable = true;
      user = "gitea";
      group = "gitea";
      mailerPasswordFile = config.age.secrets.git-mail-pw.path;
      stateDir = cfg.dataDir;
      repositoryRoot = cfg.repoDir;
      settings = {
        server.HTTP_PORT = 3001;
        service.DISABLE_REGISTRATION = true;
        # security.ALLOWED_HOST_LIST = "external,loopback,192.168.0.11";
        security.ALLOWED_HOST_LIST = "external";
        server.DOMAIN = cfg.fqdn;
        server.ROOT_URL = "https://${cfg.fqdn}";
        #service.REQUIRE_SIGNIN_VIEW = true;
        mailer = {
          ENABLED = true;
          PROTOCOL = "smtp+starttls";
          SMTP_ADDR = "exposedvm.kopatz.dev";
          SMTP_PORT = 587;
          USER = "gitea@kopatz.dev";
        };
        #server.DISABLE_SSH = true;
      };
    };
    services.anubis.instances."gitea" = {
      settings = {
        TARGET = "http://127.0.0.1:3001";
        BIND = ":3002";
        BIND_NETWORK = "tcp";
        METRICS_BIND = ":9005";
        METRICS_BIND_NETWORK = "tcp";
      };
    };
    systemd.timers.backup-gitea = {
      description = "Periodically backup gitea data";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "5m";
      };
    };
    systemd.services = {
      backup-gitea =
        let
          backupGitea = pkgs.writeShellScript "backup-gitea" ''
            set -euo pipefail

            DEST="/mnt/backups/gitea"

            mkdir -p "''${DEST}"
            ls -la /var/lib
            ls -la /var/lib/gitea
            ls ${cfg.dataDir}
            cp -r ${cfg.dataDir}/data "''${DEST}/"

            echo "Backup completed: ''${DEST}"
          '';
        in
        {
          description = "Periodically backup gitea data";
          after = [
            "mnt-backups.mount"
          ];
          requires = [
            "mnt-backups.mount"
          ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${backupGitea}";
            User = "root";
            ReadWritePaths = [ "/mnt/backups" ];
            ReadOnlyPaths = [
              "${cfg.dataDir}"
            ];
            # Basic hardening
            # CapabilityBoundingSet = "";
            CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" ];
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
    };
    services.nginx.virtualHosts."${cfg.fqdn}" = lib.mkIf cfg.enableNginx {
      forceSSL = true;
      # enableACME = true;
      useACMEHost = "kopatz.dev";
      quic = true;
      http3 = true;
      locations."/".proxyPass = "http://localhost:3002";
      locations."/robots.txt" = {
        extraConfig = ''
          add_header Content-Type text/plain;
          return 200 "User-agent: *\nDisallow: /\n";
        '';
      };
    };
  };
}
