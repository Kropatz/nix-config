{
  networking = {
    defaultGateway = "192.168.0.6";
    hostname = "server";
    useDHCP = false;
    firewall.enable = true;
    nameservers = [
      "127.0.0.1"
      "1.1.1.1"
    ];
    interfaces = {
      #"enp11s0" = {
      #  name = "eth0";
      #};
      ens33.ipv4.addresses = [{
        address = "192.168.0.6";
        prefixLength = 24;
      }];
    };
  };
}