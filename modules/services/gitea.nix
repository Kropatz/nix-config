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
  # https://docs.gitea.com/next/administration/config-cheat-sheet
  config = lib.mkIf cfg.enable {
    # Initial setup requires
    services.gitea = {
      enable = true;
      stateDir = "/1tbssd/gitea";
      settings = {
        server.HTTP_PORT = 3001;
        service.DISABLE_REGISTRATION = true;
        server.DOMAIN = cfg.fqdn;
        server.ROOT_URL = "https://${cfg.fqdn}";
        #server.DISABLE_SSH = true;
      };
    };
    services.nginx.virtualHosts."${cfg.fqdn}" = {
      forceSSL = true;
      enableACME = true;
      quic = true;
      http3 = true;
      locations."/".proxyPass = "http://localhost:3001";
    };
  };
}
