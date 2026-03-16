{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.gitea;
in
{
  options.custom.services.gitea = {
    enable = lib.mkEnableOption "Enables gitea";
    fqdn = lib.mkOption {
      type = lib.types.str;
      default = "git.kopatz.dev";
      description = "FQDN under which gitea is available";
    };
  };
  config = lib.mkIf cfg.enable {
    age.secrets.git-mail-pw = {
      file = ../../secrets/git-mail-pw.age;
      owner = "gitea";
    };
    # Initial setup requires creating an admin user with DISABLE_REGISTRATION set to false
    # https://docs.gitea.com/next/administration/config-cheat-sheet
    services.gitea = {
      enable = true;
      user = "gitea";
      group = "gitea";
      mailerPasswordFile = config.age.secrets.git-mail-pw.path;
      stateDir = "/1tbssd/gitea";
      settings = {
        server.HTTP_PORT = 3001;
        service.DISABLE_REGISTRATION = true;
        server.DOMAIN = cfg.fqdn;
        server.ROOT_URL = "https://${cfg.fqdn}";
        #service.REQUIRE_SIGNIN_VIEW = true;
        mailer = {
          ENABLED = true;
          PROTOCOL = "smtp+starttls";
          SMTP_ADDR = "kopatz.dev";
          SMTP_PORT = 587;
          USER = "gitea@kopatz.dev";
        };
        #server.DISABLE_SSH = true;
      };
    };
  services.anubis.instances."gitea" = {
    settings = {
      TARGET = "http://127.0.0.1:3001";
      BIND = ":3002";
      BIND_NETWORK = "tcp";
      METRICS_BIND = ":9005";
      METRICS_BIND_NETWORK = "tcp";
    };
  };
    services.nginx.virtualHosts."${cfg.fqdn}" = {
      forceSSL = true;
      enableACME = true;
      quic = true;
      http3 = true;
      locations."/".proxyPass = "http://localhost:3002";
      locations."/robots.txt" = {
        extraConfig = ''
          add_header Content-Type text/plain;
          return 200 "User-agent: *\nDisallow: /\n";
        '';
      };
    };
  };
}
