{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "acme-cloudflare";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables acme-cloudflare";
  };

  config = lib.mkIf cfg.enable {
    age.secrets.cloudflare-api-env = {
      file = ../../secrets/cloudflare-api-env.age;
    };
    security.acme = {
      defaults = {
        dnsResolver = "1.1.1.1:53";
      };
      certs = {
        "kopatz.dev" = {
          domain = "kopatz.dev";
          extraDomainNames = [ "*.kopatz.dev" ];
          group = "nginx";
          dnsProvider = "cloudflare";
          environmentFile = config.age.secrets."cloudflare-api-env".path;
        };
      };
    };
  };
}
