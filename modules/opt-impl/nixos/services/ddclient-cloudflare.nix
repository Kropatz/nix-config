{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "ddclient-cloudflare";
  cfg = config.custom.services.${name};
in
{

  config = lib.mkIf cfg.enable {
    age.secrets.cloudflare-api = {
      file = ../../../../secrets/cloudflare-api.age;
    };
    services.ddclient = {
      enable = true;
      domains = [ "kopatz.dev" ];
      protocol = "cloudflare";
      zone = "kopatz.dev";
      ssl = true;
      passwordFile = config.age.secrets."cloudflare-api".path;
      usev6 = "disabled";
    };
  };
}
