{ config, pkgs, lib, vars, ... }:
let
  basePath = "/mnt/1tbssd/syncthing";
in 
{
  age.secrets.syncthing-key = {
    file = ../../secrets/syncthing-key.age;
    owner = "syncthing";
    group = "syncthing";
  };
  age.secrets.syncthing-cert = {
    file = ../../secrets/syncthing-cert.age;
    owner = "syncthing";
    group = "syncthing";
  };
  services.syncthing = {
    enable = true;
    dataDir = basePath;
    openDefaultPorts = true;
    cert = "/run/agenix/syncthing-cert";
    key = "/run/agenix/syncthing-key";
    guiAddress = "0.0.0.0:8384";

    settings = {
      options.urAccepted = -1;
      options.relaysEnabled = false;
      devices.kop-pc.id = "2IEILKO-R6UVES4-N27PZRT-YLPOPR3-LTD5SXA-C65FWF3-RYD2B2Y-PEZLTAR";
      devices.kop-pc.adresses = [ "tcp://192.168.0.11:51820"];

      folders."~/sync" = {
        id = "sync";
        devices = [ "kop-pc" ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
}
