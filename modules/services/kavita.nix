{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.custom.services.kavita;
in
{
  options.custom.services.kavita = {
      enable = mkEnableOption "Enables kavita";
      https = mkOption {
        type = types.bool;
        default = true;
        description = "Should it use https?";
      };
      dir = mkOption {
        default = "/data/kavita";
        type = types.path;
        description = "data path";
      };
  };
  config =
let
  fqdn = "kavita-kopatz.duckdns.org";
  useStepCa = false; #config.services.step-ca.enable;
  useHttps = cfg.https;
  baseDir = cfg.dir;
  mangal = "${pkgs.mangal}/bin/mangal";
  githubRunnerEnabled = config.services.github-runners ? oberprofis.enable;
in lib.mkIf cfg.enable {
  networking.firewall.allowedTCPPorts = [ 5000 ];
  systemd.tmpfiles.rules = [
      (if githubRunnerEnabled then "d ${baseDir} 0750 kavita github-actions-runner -" else "d ${baseDir} 0770 kavita kavita -")
      "d ${baseDir}/manga 0770 kavita kavita -"
  ] ++ lib.optional githubRunnerEnabled "d ${baseDir}/github 0770 github-actions-runner kavita -";

  age.secrets.kavita = {
    file = ../../secrets/kavita.age;
    owner = "kavita";
    group = "kavita";
  };

 services.kavita = {
    enable = true;
    user = "kavita";
    package = let 
      backend = pkgs.kavita.backend.overrideAttrs (old: {
       patches = old.patches ++ [./kavita-patches.diff ];
      });
      kavitaPatched = pkgs.kavita.overrideAttrs (old: {
        backend = backend;
      });
     in kavitaPatched; 
    settings.Port = 5000;
    dataDir = baseDir;
    tokenKeyFile = config.age.secrets.kavita.path;
    settings.IpAddresses = "127.0.0.1";
    settings.BaseUrl = "/kavita";
  };

  #todo: base url needs new kavita version
  systemd.services.kavita = {
      after = [ "nginx.service" ] ++ lib.optional useStepCa "step-ca.service";
  };

  systemd.services.download-manga = {
    wantedBy = [ "multi-user.target" ];
    
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    startAt = "*-*-* 19:00:00";
    script = ''
      ${mangal} clear -q
      ${mangal} clear -c
      ${mangal} inline -S Mangapill -q omniscient -m first -d
      ${mangal} inline -S Mangapill --query "oshi-no-ko" --manga first --download
      ${mangal} inline -S Mangapill --query "Frieren" --manga first --download -f
      ${mangal} inline -S Mangapill --query "Chainsaw" --manga first --download
      ${mangal} inline -S Mangapill --query "Jujutsu%20Kaisen" --manga first --download
      ${mangal} inline -S Mangapill -q "ribbon_no_musha" -m first -d
    '';
    serviceConfig = {
    	PrivateTmp = true;
    	User = "kavita";
    	Group = "kavita";
        Type = "oneshot";
    	WorkingDirectory = "${baseDir}/manga";
    };
  };

 # services.nginx.virtualHosts."kopatz.ddns.net".locations."/kavita" = {
 #   proxyPass = "http://127.0.0.1:5000";
 #   extraConfig = ''
 #     add_header Access-Control-Allow-Origin *;
 #     add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
 #     add_header Access-Control-Allow-Headers "Authorization, Origin, X-Requested-With, Content-Type, Accept";
 #   '';
 # };
  security.acme.certs."${fqdn}" = lib.mkIf useStepCa { 
    server = "https://127.0.0.1:8443/acme/acme/directory";
  };
  services.nginx.virtualHosts."${fqdn}" = {
    forceSSL = useHttps;
    enableACME = useHttps;
    quic = useHttps;
    http3 = useHttps;
    locations."/".proxyPass = "http://127.0.0.1:5000";
    locations."/".extraConfig = ''
      more_clear_headers 'x-frame-options';
      add_header Access-Control-Allow-Origin *;
      add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
      add_header Access-Control-Allow-Headers "Authorization, Origin, X-Requested-With, Content-Type, Accept";
    '';
  };
};
}
