{ config, pkgs, lib, inputs, ... }:
{
  age.secrets.duckdns = {
    file = ../../secrets/duckdns.age;
  };
  services.duckdns = {
    enable = true;
    tokenFile = config.age.secrets.duckdns.path;
    domains = [ "kavita-kopatz" ];
  };
}
