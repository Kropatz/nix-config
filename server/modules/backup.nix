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
            ];
            repository = "/mnt/2tb/restic";
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
	    timerConfig = {
		OnCalendar = "*-*-03,06,09,12,15,18,21,24,27,30 00:00:00";
		Persistent = true;
	    };
            repository = "s3:s3.us-west-002.backblazeb2.com/kop-bucket";
	};
    };
  };
}
