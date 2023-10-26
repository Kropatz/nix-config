{ config, pkgs, lib, inputs, ... }:
{
  age.secrets.restic-pw = {
    file = ../secrets/restic-pw.age;
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
            repository = "/mnt/backup";
        };
    };
  };
}