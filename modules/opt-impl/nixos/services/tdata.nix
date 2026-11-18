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
      http2 = config.custom.vars.nginx.useHttp2;
      useACMEHost = "kopatz.dev";
      extraConfig = ''
        ${config.custom.vars.nginx.allowOnlyInternalIps}
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:4000";
        proxyWebsockets = true;
      };
    };
    services.nginx.virtualHosts."tui.kopatz.dev" = {
      forceSSL = true;
      http2 = config.custom.vars.nginx.useHttp2;
      useACMEHost = "kopatz.dev";
      extraConfig = ''
        ${config.custom.vars.nginx.allowOnlyInternalIps}
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:4001";
        proxyWebsockets = true;
      };
    };
  };
}
