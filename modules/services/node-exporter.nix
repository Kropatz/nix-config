{
  pkgs,
  config,
  lib,
  ...
}:
let
in
{
  services.prometheus.exporters.node = {
    enable = true;
    firewallRules = ''
      ip saddr ${config.custom.vars.serverIp} tcp dport 9100 counter accept comment node_exporter_allow_from_main_server
    '';
  };
}
