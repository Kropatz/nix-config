{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "tdata";
  cfg = config.custom.services.${name};
in
{

  config = lib.mkIf cfg.enable {
    # nginx reverse proxy
    services.nginx.enable = true;
    services.nginx.virtualHosts."tdata.kopatz.dev" = {
      forceSSL = true;
      useACMEHost = "kopatz.dev";
      locations."/" = {
        proxyPass = "http://127.0.0.1:4000";
        proxyWebsockets = true;
      };
    };
    services.nginx.virtualHosts."tui.kopatz.dev" = {
      forceSSL = true;
      useACMEHost = "kopatz.dev";
      locations."/" = {
        proxyPass = "http://127.0.0.1:4001";
        proxyWebsockets = true;
      };
    };
  };
}
