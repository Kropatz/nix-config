{ config, pkgs, lib, inputs, ... }:
{
  age.secrets.restic-pw = {
    file = ../secrets/restic-pw.age;
  };
  age.secrets.restic-s3 = {
    file = ../secrets/restic-s3.age;
  };
  services.restic = {
    backups = {
        localbackup = {
            exclude = [
                "/home/*/.cache"
            ];
            initialize = true;
            passwordFile = config.age.secrets.restic-pw.path;
            paths = [
                "/home"
                "/var/backup/postgresql"
                "/mnt/250ssd/matrix-synapse/media_store/"
                "/mnt/250ssd/nextcloud"
                "/mnt/250ssd/paperless"
            ];
            pruneOpts = [ "--keep-daily 7" "--keep-weekly 10" "--keep-monthly 12" "--keep-yearly 75" ];
            repository = "/mnt/2tb/restic";
        };
        localbackup-1tb = {
            initialize = true;
            passwordFile = config.age.secrets.restic-pw.path;
            paths = [
                "/home"
		        "/var/backup/postgresql"
		        "/mnt/250ssd/matrix-synapse/media_store/"
		        "/mnt/250ssd/nextcloud"
		        "/mnt/250ssd/paperless"
            ];
	        exclude = [
                "/home/*/.cache"
            ];
            repository = "/mnt/1tb/restic";
            pruneOpts = [ "--keep-daily 5" "--keep-weekly 5" "--keep-monthly 12" "--keep-yearly 75" ];
            timerConfig = {
                OnCalendar = "*-*-03,06,09,12,15,18,21,24,27,30 02:00:00";
                Persistent = true;
            };
        };
        remotebackup = { 
	        exclude = [
                "/home/*/.cache"
            ];
            initialize = true;
            passwordFile = config.age.secrets.restic-pw.path;
	        environmentFile = config.age.secrets.restic-s3.path;
            paths = [
                "/home"
            ];
            pruneOpts = [ "--keep-daily 5" "--keep-weekly 5" "--keep-monthly 12" "--keep-yearly 75" ];
            timerConfig = {
		        OnCalendar = "*-*-03,06,09,12,15,18,21,24,27,30 00:00:00";
		        Persistent = true;
	        };
            repository = "s3:s3.us-west-002.backblazeb2.com/kop-bucket";
	    };
    };
  };
}
