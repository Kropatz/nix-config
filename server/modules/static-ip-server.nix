{
  networking = {
    defaultGateway = "192.168.0.1";
    useDHCP = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 53 80 443 ];
      allowedUDPPorts = [ 53 5000 ];
    };
    nameservers = [
      "127.0.0.1"
      "1.1.1.1"
    ];
    interfaces = {
      "enp0s31f6" = {
        name = "eth0";
	      ipv4.addresses = [{
          address = "192.168.0.6";
          prefixLength = 24;
        }];
      };
    };
  };
}