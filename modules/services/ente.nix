{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.custom.services.ente;
in
{
  options.custom.services.ente = {
    enable = mkEnableOption "Enables ente";
  };
  config = lib.mkIf cfg.enable {
    services.cron = {
      enable = true;
      systemCronJobs = [
        "0 23 * * *      root    /data/ente/backup/backup.sh"
        "0 23 * * *      root    /data/ente-public/backup/backup.sh"
      ];
    };
  };
}
