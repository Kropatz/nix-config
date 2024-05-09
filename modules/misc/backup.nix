{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.custom.misc.backup;
in
{
   options.custom.misc.backup = {
      enable = mkEnableOption "Enables backup";
   };

   config = let 
    kavita = "/mnt/1tbssd/kavita";
    gitolite = "/var/lib/gitolite";
    syncthing = [ "/synced/default/" "/synced/work_drive/" ];
    syncthingFull = syncthing ++ [ "/synced/fh/" "/synced/books/" ];
    excludePaths = [ "/home/**/Cache" "/home/**/.cache" "/home/**/__pycache__" "/home/**/node_modules" "/home/**/venv" ];
    excludePathsRemote = excludePaths ++ [ "/home/**/dont_remotebackup" ];
    backupPathsSmall = [ "/home" "/var/backup/postgresql" gitolite ] ++ syncthing;
    backupPathsMedium = [ "/home" "/var/backup/postgresql" "/mnt/250ssd/matrix-synapse/media_store/" "/mnt/250ssd/paperless" gitolite ] ++ syncthing;
    backupPathsFull = [ "/home" "/var/backup/postgresql" "/mnt/250ssd/matrix-synapse/media_store/" "/mnt/250ssd/paperless" kavita gitolite ] ++ syncthingFull;
    checkStorageSpace = pkgs.writeShellApplication {
      name = "checkBackupStorageSpace";
      text = ''
        # Check how much space is used by the backup paths
        echo "Checking storage space (small) with excluded paths..."
        du -sch ${builtins.concatStringsSep " " (map (x: "--exclude=" + x) excludePaths)} ${builtins.concatStringsSep " " backupPathsSmall} 
        echo "Checking storage space (small) with excluded paths (remote)..."
        du -sch ${builtins.concatStringsSep " " (map (x: "--exclude=" + x) excludePathsRemote)} ${builtins.concatStringsSep " " backupPathsSmall}
        echo "Checking storage space (medium) with excluded paths..."
        du -sch ${builtins.concatStringsSep " " (map (x: "--exclude=" + x) excludePaths)} ${builtins.concatStringsSep " " backupPathsMedium} 
        echo "Checking storage space (medium) with excluded paths (remote)..."
        du -sch ${builtins.concatStringsSep " " (map (x: "--exclude=" + x) excludePathsRemote)} ${builtins.concatStringsSep " " backupPathsMedium}
        echo "Checking storage space (full) with excluded paths..."
        du -sch ${builtins.concatStringsSep " " (map (x: "--exclude=" + x) excludePaths)} ${builtins.concatStringsSep " " backupPathsFull}
        echo "Checking storage space (full) with excluded paths (remote)..."
        du -sch ${builtins.concatStringsSep " " (map (x: "--exclude=" + x) excludePathsRemote)} ${builtins.concatStringsSep " " backupPathsFull}
      '';
    };
in mkIf cfg.enable {
  environment.systemPackages = with pkgs; [ checkStorageSpace ];
  age.secrets.restic-pw = {
    file = ../secrets/restic-pw.age;
  };
  age.secrets.restic-s3 = {
    file = ../secrets/restic-s3.age;
  };
  age.secrets.restic-gdrive = {
    file = ../secrets/restic-gdrive.age;
  };
  services.restic = {
    backups = {
        localbackup = {
            initialize = true;
            passwordFile = config.age.secrets.restic-pw.path;
            exclude = excludePaths;
            paths = backupPathsFull;
            pruneOpts = [ "--keep-daily 7" "--keep-weekly 3" "--keep-monthly 3" "--keep-yearly 3" ];
            repository = "/mnt/2tb/restic";
        };
        localbackup-1tb-ssd = {
            initialize = true;
            passwordFile = config.age.secrets.restic-pw.path;
            exclude = excludePaths;
            paths = backupPathsFull;
            pruneOpts = [ "--keep-daily 7" "--keep-weekly 3" "--keep-monthly 3" "--keep-yearly 3" ];
            repository = "/mnt/1tbssd/restic";
        };
        localbackup-1tb = {
            initialize = true;
            passwordFile = config.age.secrets.restic-pw.path;
            exclude = excludePaths;
            paths = backupPathsFull;
            repository = "/mnt/1tb/restic";
            pruneOpts = [ "--keep-daily 5" "--keep-weekly 3" "--keep-monthly 3" "--keep-yearly 3" ];
            timerConfig = {
                OnCalendar = "*-*-03,06,09,12,15,18,21,24,27,30 02:00:00";
                Persistent = true;
            };
        };
        remotebackup-gdrive = {
            initialize = true;
            passwordFile = config.age.secrets.restic-pw.path;
            exclude = excludePathsRemote;
            paths = backupPathsMedium;
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
            exclude = excludePathsRemote;
            paths = backupPathsSmall;
            pruneOpts = [ "--keep-daily 5" "--keep-weekly 3" "--keep-monthly 3" "--keep-yearly 3" ];
            timerConfig = {
              OnCalendar = "*-*-03,06,09,12,15,18,21,24,27,30 00:00:00";
              Persistent = true;
            };
            repository = "s3:s3.us-west-002.backblazeb2.com/kop-bucket";
      };
    };
  };
  };
}
