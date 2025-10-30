{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.dnsmasq;
in
{
  options.custom.services.dnsmasq = {
    enable = mkEnableOption "Enables dnsmaq service";
    server = mkOption { type = types.listOf types.string; };
  };
  config = mkIf cfg.enable {
    #networking.resolvconf.enable = false;

    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = true;
      settings.server = cfg.server;
      extraConfig = ''
        interface=lo
        bind-interfaces
        listen-address=127.0.0.1
        cache-size=1000

        no-negcache
      '';
    };
  };
}
