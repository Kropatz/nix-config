{ config, pkgs, lib, inputs, ... }:
{

  networking.firewall.allowedTCPPorts = [ 5000 ];
  age.secrets.kavita = {
    file = ../secrets/kavita.age;
    owner = "kavita";
    group = "kavita";
  };
  services.kavita = {
    enable = true;
    user = "kavita";
    port = 5000;
    dataDir = "/mnt/250ssd/kavita";
    tokenKeyFile = config.age.secrets.kavita.path;
  };
}
