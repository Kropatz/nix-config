{ config, pkgs, lib, inputs, ... }:
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
	address = "192.168.2.1";
	mediaDir = "/mnt/250ssd/paperless";
    };
}
