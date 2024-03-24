{ config, pkgs, lib, inputs, ... }:
let
  fqdn = "kavita.home.arpa";
  useHttps = config.services.step-ca.enable;
  baseDir = "/mnt/1tbssd/kavita";
  mangal = "${pkgs.mangal}/bin/mangal";
in
{
  networking.firewall.allowedTCPPorts = [ 5000 ];
  systemd.tmpfiles.rules = [
      "d ${baseDir} 0770 kavita kavita -"
      "d ${baseDir}/manga 0770 kavita kavita -"
  ];
  age.secrets.kavita = {
    file = ../secrets/kavita.age;
    owner = "kavita";
    group = "kavita";
  };
  services.kavita = {
    enable = true;
    user = "kavita";
    port = 5000;
    dataDir = baseDir;
    tokenKeyFile = config.age.secrets.kavita.path;
  };

  #todo: base url needs new kavita version
  systemd.services.kavita = {
      preStart = ''
        umask u=rwx,g=rx,o=
        cat > "/mnt/1tbssd/kavita/config/appsettings.json" <<EOF
        {
          "TokenKey": "$(cat ${config.age.secrets.kavita.path})",
          "Port": 5000,
          "BaseUrl" : "/books",
          "IpAddresses": "${lib.concatStringsSep "," ["0.0.0.0" "::"]}"
        }
        EOF
      '';
  };

  systemd.services.download-manga = {
    wantedBy = [ "multi-user.target" ];
    
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    startAt = "*-*-* 00:00:00";
    script = ''
      ${mangal} inline -S Mangapill -q omniscient -m first -d
    '';
    serviceConfig = {
    	PrivateTmp = true;
    	User = "kavita";
    	Group = "kavita";
        Type = "oneshot";
    	WorkingDirectory = "${baseDir}/manga";
    };
  };

  security.acme.certs."${fqdn}".server = "https://127.0.0.1:8443/acme/acme/directory";
  services.nginx.virtualHosts."${fqdn}" = {
    forceSSL = useHttps;
    enableACME = useHttps;
    quic = useHttps;
    http3 = useHttps;
    locations."/".proxyPass = "http://127.0.0.1:5000";
    locations."/".extraConfig = ''
      add_header Access-Control-Allow-Origin *;
      add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
      add_header Access-Control-Allow-Headers "Authorization, Origin, X-Requested-With, Content-Type, Accept";
    '';
  };
}
