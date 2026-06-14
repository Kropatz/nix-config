{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.services."node-exporter";
in
{

  config = lib.mkIf cfg.enable {
    networking.firewall.extraInputRules = "ip saddr ${config.custom.vars.serverIp} tcp dport ${toString config.services.prometheus.exporters.node.port} counter accept comment node_exporter__allow_from_main_server";
    services.prometheus.exporters.node = {
      enable = true;
    };
  };
}
