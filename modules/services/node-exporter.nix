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
    openFirewall = true;
    firewallRules = ''
      ip saddr 192.168.0.10 tcp dport 9100 counter accept comment node_exporter_allow_from_main_server
    '';
  };
}
