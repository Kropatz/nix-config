{ lib, index, ... }:

let
  mac = "00:00:00:00:00:01";
in
{
  microvm.interfaces = [
    {
      id = "vm${toString index}";
      type = "tap";
      inherit mac;
    }
  ];

  networking.useNetworkd = true;

  systemd.network.networks."10-eth" = {
    matchConfig.MACAddress = mac;
    # Static IP configuration
    address = [
      "10.0.0.${toString index}/32"
      "fec0::${lib.toHexString index}/128"
    ];
    routes = [
      {
        # A route to the host
        Destination = "10.0.0.0/32";
        GatewayOnLink = true;
      }
      {
        # Default route
        Destination = "0.0.0.0/0";
        Gateway = "10.0.0.0";
        GatewayOnLink = true;
      }
      {
        # Default route
        Destination = "::/0";
        Gateway = "fec0::";
        GatewayOnLink = true;
      }
    ];
    networkConfig = {
      DNS = [
        "192.168.0.10"
      ];
    };
  };
}
