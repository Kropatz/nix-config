{ config, pkgs, lib, inputs, ... }:
{
  age.secrets.duckdns = {
    file = ../../secrets/duckdns.age;
  };
  services.ddclient = {
    enable = true;
    protocol = "duckdns";
    passwordFile = config.age.secrets.duckdns.path;
    domains = [ "wachbirn.duckdns.org" ];
  };
}
