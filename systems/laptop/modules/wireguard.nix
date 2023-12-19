{ config, pkgs, lib, inputs, ... }:
{

  age.secrets.wireguard-private = {
    file = ../secrets/wireguard-private.age;
  };

  systemd.network = {
    enable = true;
    netdevs."10-wg0" = {
      enable = true;
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
        MTUBytes = "1300";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.wireguard-private.path;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            AllowedIPs = [
              "192.168.2.0/24"
            ];
            Endpoint = "kopatz.ddns.net:51820";
            PersistentKeepalive = 25;
            PublicKey = "vyHNUy97R1cvqEvElznPpFQtoqm7WUHnT96UP6Dquwc=";
          };
        }
      ];
    };
    networks.wg0 = {
      # See also man systemd.network
      matchConfig.Name = "wg0";
      # IP addresses the client interface will have
      address = [
        "192.168.2.22/24"
      ];
      #DHCP = "no";
      #dns = [ "fc00::53" ];
      #ntp = [ "fc00::123" ];
      #gateway = [
      #  "fc00::1"
      #  "10.100.0.1"
      #];
      networkConfig = {
        IPv6AcceptRA = false;
      };
    };
  };
}
