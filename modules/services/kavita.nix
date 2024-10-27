{ config, pkgs, lib, inputs, ... }:
with lib;
let cfg = config.custom.services.kavita;
in {
  options.custom.services.kavita = {
    enable = mkEnableOption "Enables kavita";
    https = mkOption {
      type = types.bool;
      default = true;
      description = "Should it use https?";
    };
    autoDownload = mkOption {
      type = types.bool;
      default = true;
      description = "Should it auto download?";
    };
    dir = mkOption {
      default = "/data/kavita";
      type = types.path;
      description = "data path";
    };
    isTest = mkEnableOption "Is this a test vm?";
  };
  config = let
    fqdn = "kavita-kopatz.duckdns.org";
    useStepCa = false; # config.services.step-ca.enable;
    useHttps = cfg.https;
    baseDir = cfg.dir;
    mangal = "${pkgs.mangal}/bin/mangal";
    githubRunnerEnabled = config.services.github-runners ? oberprofis.enable;
  in lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 5000 ];
    systemd.tmpfiles.rules = [
      (if githubRunnerEnabled then
        "d ${baseDir} 0750 kavita github-actions-runner -"
      else
        "d ${baseDir} 0770 kavita kavita -")
      "d ${baseDir}/manga 0770 kavita kavita -"
    ] ++ lib.optional githubRunnerEnabled
      "d ${baseDir}/github 0770 github-actions-runner kavita -";

    age.secrets.kavita = mkIf (!cfg.isTest) {
      file = ../../secrets/kavita.age;
      owner = "kavita";
      group = "kavita";
    };

    services.kavita = {
      enable = true;
      user = "kavita";
      package = let
        backend = pkgs.unstable.kavita.backend.overrideAttrs
          (old: { patches = old.patches ++ [ ./kavita-patches-chapter-parsing.diff]; });
        kavitaPatched = pkgs.unstable.kavita.overrideAttrs (old: { backend = backend; });
      in kavitaPatched;
      settings = {
        Port = 5000;
        IpAddresses = "127.0.0.1";
        BaseUrl = "/kavita";
      };
      dataDir = baseDir;
      tokenKeyFile = if cfg.isTest then
        (builtins.toFile "test"
          "wWKNeGUslGILrUUp8Dnn4xyYnivZWBb8uqjKg3ALyCs7reV5v3CtE/E2b6i0Mwz1Xw1p9a0wcduRDNoa8Yh8kQ==")
      else
        config.age.secrets.kavita.path;
    };

    #todo: base url needs new kavita version
    systemd.services = {
      kavita = {
        after = [ "nginx.service" ] ++ lib.optional useStepCa "step-ca.service";
      };
      download-manga = mkIf cfg.autoDownload {
        wantedBy = [ "multi-user.target" ];

        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        startAt = "*-*-* 19:00:00";
        restartIfChanged = false;
        script = ''
          ${mangal} clear -q
          ${mangal} clear -c
          ${mangal} inline -S Mangapill -q omniscient -m first -d
          ${mangal} inline -S Mangapill --query "oshi-no-ko" --manga first --download
          ${mangal} inline -S Mangapill --query "Frieren" --manga first --download -f
          ${mangal} inline -S Mangapill --query "Chainsaw" --manga first --download
          ${mangal} inline -S Mangapill --query "Jujutsu%20Kaisen" --manga first --download
          ${mangal} inline -S Mangapill --query "solo-leveling" --manga first --download
          ${mangal} inline -S Mangapill --query "the-greatest-real-estate" --manga first --download
          ${mangal} inline -S Mangapill --query "66666_years" --manga first --download
          ${mangal} inline -S Mangapill --query "Return_of_the_blossoming" --manga first --download
          ${mangal} inline -S Mangapill --query "path_of_the_shaman" --manga first --download
          ${mangal} inline -S Mangapill --query "pick_me_up" --manga first --download
          ${mangal} inline -S Mangapill --query "revenge_of_the_iron_blooded" --manga first --download
          ${mangal} inline -S Mangapill --query "northern_blade" --manga first --download
          ${mangal} inline -S Mangapill --query "Dungeon_reset" --manga first --download
          ${mangal} inline -S Mangapill --query "iruma-kun" --manga first --download
          ${mangal} inline -S Manganato --query "grand_blue" --manga first --download
          ${mangal} inline -S Manganato --query "sss-class_suicide" --manga first --download
          ${mangal} inline -S Manganato --query "cultivation_chat" --manga first --download
          ${mangal} inline -S Manganato --query "gokushufudo" --manga first --download
          ${mangal} inline -S Manganato --query "slime" --manga first --download
        '';
        serviceConfig = {
          PrivateTmp = true;
          User = "kavita";
          Group = "kavita";
          Type = "oneshot";
          WorkingDirectory = "${baseDir}/manga";
        };
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
      server = "https://127.0.0.1:8443/acme/kop-acme/directory";
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
