{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.custom.misc.backup;
in
{
  options.custom.misc.backup = {
    enable = mkEnableOption "Enables backup";
    small = lib.mkOption {
      type = types.listOf types.str;
      description = "paths to include in the small backup";
    };
    medium = lib.mkOption {
      type = types.listOf types.str;
      default = cfg.small;
      description = "paths to include in the medium backup";
    };
    large = lib.mkOption {
      type = types.listOf types.str;
      default = cfg.small // cfg.medium;
      description = "paths to include in the large backup";
    };
    excludePaths = lib.mkOption {
      type = types.listOf types.str;
      default = [ "**/Cache" "**/.cache" "**/__pycache__" "**/node_modules" "**/venv" "*.o" "*.out" ];
      description = "paths to exclude from the backup";
    };
    excludePathsRemote = lib.mkOption {
      type = types.listOf types.str;
      default = cfg.excludePaths ++ [ "**/dont_remotebackup" ];
      description = "paths to exclude from the remote backup";
    };
  };

  config =
    let
      checkStorageSpace = pkgs.writeShellApplication {
        name = "checkBackupStorageSpace";
        text = ''
          # Check how much space is used by the backup paths
          echo "Checking storage space (small) with excluded paths..."
          du -sch ${builtins.concatStringsSep " " (map (x: "--exclude=" + x) cfg.excludePaths)} ${builtins.concatStringsSep " " cfg.small} 
          echo "Checking storage space (small) with excluded paths (remote)..."
          du -sch ${builtins.concatStringsSep " " (map (x: "--exclude=" + x) cfg.excludePathsRemote)} ${builtins.concatStringsSep " " cfg.small}
          echo "Checking storage space (medium) with excluded paths..."
          du -sch ${builtins.concatStringsSep " " (map (x: "--exclude=" + x) cfg.excludePaths)} ${builtins.concatStringsSep " " cfg.medium} 
          echo "Checking storage space (medium) with excluded paths (remote)..."
          du -sch ${builtins.concatStringsSep " " (map (x: "--exclude=" + x) cfg.excludePathsRemote)} ${builtins.concatStringsSep " " cfg.medium}
          echo "Checking storage space (full) with excluded paths..."
          du -sch ${builtins.concatStringsSep " " (map (x: "--exclude=" + x) cfg.excludePaths)} ${builtins.concatStringsSep " " cfg.large}
          echo "Checking storage space (full) with excluded paths (remote)..."
          du -sch ${builtins.concatStringsSep " " (map (x: "--exclude=" + x) cfg.excludePathsRemote)} ${builtins.concatStringsSep " " cfg.large}
        '';
      };
    in
    mkIf cfg.enable {
      environment.systemPackages = with pkgs; [ checkStorageSpace ];
      age.secrets.restic-pw = {
        file = ../../secrets/restic-pw.age;
      };
      age.secrets.restic-s3 = {
        file = ../../secrets/restic-s3.age;
      };
      age.secrets.restic-gdrive = {
        file = ../../secrets/restic-gdrive.age;
      };
      age.secrets.restic-internxt = {
        file = ../../secrets/restic-internxt.age;
      };
      services.restic = {
        backups = {
          #localbackup = {
          #    initialize = true;
          #    passwordFile = config.age.secrets.restic-pw.path;
          #    exclude = cfg.excludePaths;
          #    paths = cfg.large;
          #    pruneOpts = [ "--keep-daily 7" "--keep-weekly 3" "--keep-monthly 3" "--keep-yearly 3" ];
          #    repository = "/mnt/2tb/restic";
          #};
          localbackup-1tb-ssd = {
            initialize = true;
            passwordFile = config.age.secrets.restic-pw.path;
            exclude = cfg.excludePaths;
            paths = cfg.large;
            timerConfig = {
              OnCalendar = "04:00";
              Persistent = true;
            };
            pruneOpts = [ "--keep-daily 7" "--keep-weekly 3" "--keep-monthly 3" "--keep-yearly 3" ];
            repository = "/1tbssd/restic";
          };
          #localbackup-1tb = {
          #    initialize = true;
          #    passwordFile = config.age.secrets.restic-pw.path;
          #    exclude = cfg.excludePaths;
          #    paths = cfg.large;
          #    repository = "/mnt/1tb/restic";
          #    pruneOpts = [ "--keep-daily 5" "--keep-weekly 3" "--keep-monthly 3" "--keep-yearly 3" ];
          #    timerConfig = {
          #        OnCalendar = "*-*-03,06,09,12,15,18,21,24,27,30 02:00:00";
          #        Persistent = true;
          #    };
          #};
          remotebackup-gdrive = {
            initialize = true;
            passwordFile = config.age.secrets.restic-pw.path;
            exclude = cfg.excludePathsRemote;
            paths = cfg.medium;
            rcloneConfigFile = config.age.secrets.restic-gdrive.path;
            repository = "rclone:it-experts:backup";
            pruneOpts = [ "--keep-daily 5" "--keep-weekly 3" "--keep-monthly 3" "--keep-yearly 3" ];
            timerConfig = {
              OnCalendar = "*-*-03,06,09,12,15,18,21,24,27,30 02:00:00";
              Persistent = true;
            };
          };
          remotebackup = {
            initialize = true;
            passwordFile = config.age.secrets.restic-pw.path;
            environmentFile = config.age.secrets.restic-s3.path;
            exclude = cfg.excludePathsRemote;
            paths = cfg.small;
            pruneOpts = [ "--keep-daily 5" "--keep-weekly 3" "--keep-monthly 3" "--keep-yearly 3" ];
            timerConfig = {
              OnCalendar = "*-*-03,06,09,12,15,18,21,24,27,30 02:00:00";
              Persistent = true;
            };
            repository = "s3:s3.us-west-002.backblazeb2.com/kop-bucket";
          };
          remotebackup-large = let cli = "${pkgs.internxt-cli}/bin/internxt"; in {
            initialize = true;
            passwordFile = config.age.secrets.restic-pw.path;
            environmentFile = config.age.secrets.restic-internxt.path;
            exclude = cfg.excludePathsRemote;
            paths = cfg.large;
            backupPrepareCommand = ''
                LOGGED_IN=$(${cli} whoami | grep "You are logged in")
                if [ -z "$LOGGED_IN" ]; then
                  echo "Logging in as $USERNAME"
                  ${cli} login --non-interactive -e $USERNAME -p $PASSWORD
                  LOGGED_IN=$(${cli} whoami | grep "You are logged in")
                  if [ -z "$LOGGED_IN" ]; then
                    echo "Internxt CLI login failed. Aborting backup."
                    exit 1
                  fi
                fi
                WEBDAV_ENABLED=$(${cli} webdav status | grep "status: online" | wc -l)
                if [ "$WEBDAV_ENABLED" -eq 0 ]; then
                  ${cli} webdav enable
                  WEBDAV_ENABLED=$(${cli} webdav status | grep "status: online" | wc -l)
                  if [ "$WEBDAV_ENABLED" -eq 0 ]; then
                    echo "Internxt WebDAV enable failed. Aborting backup."
                    exit 1
                  fi
                fi
            '';
            backupCleanupCommand = ''
              WEBDAV_ENABLED=$(${cli} webdav status | grep "status: online" | wc -l)
              if [ "$WEBDAV_ENABLED" -eq 1 ]; then
                ${cli} webdav disable
              fi
            '';
            pruneOpts = [ "--keep-daily 5" "--keep-weekly 3" "--keep-monthly 3" "--keep-yearly 3" ];
            timerConfig = {
              OnCalendar = "*-*-03,06,09,12,15,18,21,24,27,30 02:00:00";
              Persistent = true;
            };
            rcloneConfig = { 
                type = "webdav"; 
                url = "https://127.0.0.1:3005";
            };
            rcloneOptions = { "no-check-certificate" = true; };
            repository = "rclone:internxt:backup";
          };
        };
      };
    };
}
