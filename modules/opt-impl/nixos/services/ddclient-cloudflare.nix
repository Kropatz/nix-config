{
  config,
  pkgs,
  lib,
  ...
}:
{
  age.secrets.cloudflare-api = {
    file = ../../secrets/cloudflare-api.age;
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
}
