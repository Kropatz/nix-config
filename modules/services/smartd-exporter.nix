{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "smartd-exporter";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables smartd monitoring";
  };
  config = lib.mkIf cfg.enable {
    networking.firewall.extraInputRules = "ip saddr 192.168.0.10 tcp dport ${toString config.services.prometheus.port} counter accept comment smartctl_allow_from_main_server";
    services.prometheus = {
      enable = true;
      port = 9000;
      globalConfig.scrape_interval = "1h";
      # retentionTime = "15d";
      #stateDir = "../../${base}/prometheus";
      exporters.smartctl = {
        enable = true;
        maxInterval = "2h";
      };
      scrapeConfigs = [
        {
          job_name = "smart";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"
              ];
              labels = {
                instance = "smart";
              };
            }
          ];
        }
      ];
    };

  };
}
