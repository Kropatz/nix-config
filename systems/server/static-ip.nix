{ config, vars, ...}:
let
 ip = vars.ipv4;
 interface = vars.interface;
in
{
  networking = {
    defaultGateway = "192.168.0.1";
    useDHCP = false;
    firewall = {
      enable = true;
      allowedUDPPorts = [ 5000 ];
    };
    nameservers = [
      "127.0.0.1"
      "1.1.1.1"
    ];
    interfaces = {
      ${interface} = {
        name = "eth0";
        ipv4.addresses = [{
          address = ip;
          prefixLength = 24;
        }];
      };
    };
  };
}
