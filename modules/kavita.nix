{ config, pkgs, lib, inputs, ... }:
let
  fqdn = "kavita.local";
  useHttps = config.services.step-ca.enable;
in
{
  networking.firewall.allowedTCPPorts = [ 5000 ];
  age.secrets.kavita = {
    file = ../secrets/kavita.age;
    owner = "kavita";
    group = "kavita";
  };
  services.kavita = {
    enable = true;
    user = "kavita";
    port = 5000;
    dataDir = "/mnt/250ssd/kavita";
    tokenKeyFile = config.age.secrets.kavita.path;
  };
  #todo: base url needs new kavita version
  systemd.services.kavita = {
      preStart = ''
        umask u=rwx,g=rx,o=
        cat > "/mnt/250ssd/kavita/config/appsettings.json" <<EOF
        {
          "TokenKey": "$(cat ${config.age.secrets.kavita.path})",
          "Port": 5000,
          "BaseUrl" : "/books",
          "IpAddresses": "${lib.concatStringsSep "," ["0.0.0.0" "::"]}"
        }
        EOF
      '';
  };

  security.acme.certs."${fqdn}".server = "https://127.0.0.1:8443/acme/acme/directory";
  services.nginx.virtualHosts."${fqdn}" = {
    forceSSL = useHttps;
    enableACME = useHttps;
    locations."/".proxyPass = "http://127.0.0.1:5000";
    locations."/".extraConfig = ''
      add_header Access-Control-Allow-Origin *;
      add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
      add_header Access-Control-Allow-Headers "Authorization, Origin, X-Requested-With, Content-Type, Accept";
    '';
  };
}
