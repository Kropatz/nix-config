{ config, pkgs, lib, inputs, vars, ... }:
let 
  ip = vars.ipv4;
  wireguardIp = vars.wireguardIp;
in
{
    networking.firewall.allowedTCPPorts = [ 28981 ];
    age.secrets.paperless = {
        file = ../secrets/paperless.age;
        owner = "paperless";
        group = "paperless";
    };
    services.paperless = {
	enable = true;
	port = 28981;
	passwordFile = config.age.secrets.paperless.path;
	address = wireguardIp;
	mediaDir = "/mnt/250ssd/paperless";
    };
}
