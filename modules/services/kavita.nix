{ config, pkgs, lib, inputs, ... }:
let
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
    file = ../../secrets/kavita.age;
    owner = "kavita";
    group = "kavita";
  };
  services.kavita = {
    enable = true;
    user = "kavita";
    settings.Port = 5000;
    dataDir = baseDir;
    tokenKeyFile = config.age.secrets.kavita.path;
    package = pkgs.my-kavita;
    settings.BaseUrl = "/kavita";
  };

  #todo: base url needs new kavita version
  systemd.services.kavita = {
      after = [ "nginx.service" ];
  };

  systemd.services.download-manga = {
    wantedBy = [ "multi-user.target" ];
    
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    startAt = "*-*-* 19:00:00";
    script = ''
      ${mangal} inline -S Mangapill -q omniscient -m first -d
      ${mangal} inline -S Mangapill --query "oshi-no-ko" --manga first --download
      ${mangal} inline -S Mangapill --query "Frieren" --manga first --download
      ${mangal} inline -S Mangapill --query "Chainsaw" --manga first --download
    '';
    serviceConfig = {
    	PrivateTmp = true;
    	User = "kavita";
    	Group = "kavita";
        Type = "oneshot";
    	WorkingDirectory = "${baseDir}/manga";
    };
  };

  services.nginx.virtualHosts."kopatz.ddns.net".locations."/kavita" = {
    proxyPass = "http://127.0.0.1:5000";
    extraConfig = ''
      add_header Access-Control-Allow-Origin *;
      add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
      add_header Access-Control-Allow-Headers "Authorization, Origin, X-Requested-With, Content-Type, Accept";
    '';
  };
}
