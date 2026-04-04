{ ... }:
let
  acme = "https://127.0.0.1:8443/acme/kop-acme/directory";
in
{
  security.acme.certs."tdata.home.arpa".server = acme;
  security.acme.certs."tui.home.arpa".server = acme;
  # nginx reverse proxy
  services.nginx.enable = true;
  services.nginx.virtualHosts."tdata.home.arpa" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:4000";
      proxyWebsockets = true;
    };
  };
  services.nginx.virtualHosts."tui.home.arpa" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:4001";
      proxyWebsockets = true;
    };
  };
}
