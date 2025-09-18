{ config, pkgs, lib, inputs, ... }:
{

  age.secrets.wireguard-client = {
    file = ../../secrets/wireguard-client.age;
  };

  systemd.network.networks.wg0 = {
    dns = [ "192.168.2.1" ];
  };
  networking.wg-quick.interfaces = {
    wg0 = {
      # General Settings
      autostart = true;
      privateKeyFile = config.age.secrets.wireguard-client.path;
      listenPort = 51820;
      dns = [ "192.168.2.1" ];
      address = [ "192.168.2.22/24" ];
      peers = [
        {
          #allowedIPs = [ "192.168.2.0/24" "192.168.0.0/24" ];
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "kopatz.dev:51820";
          publicKey = "vyHNUy97R1cvqEvElznPpFQtoqm7WUHnT96UP6Dquwc=";
          persistentKeepalive = 30;
        }
      ];
    };
    wg1 = {
      # General Settings
      autostart = false;
      privateKeyFile = config.age.secrets.wireguard-client.path;
      listenPort = 51820;
      dns = [ "192.168.2.1" ];
      address = [ "192.168.2.22/24" ];
      peers = [
        {
          allowedIPs = [ "192.168.2.0/24" "192.168.0.0/24" ];
          #allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "kopatz.dev:51820";
          publicKey = "vyHNUy97R1cvqEvElznPpFQtoqm7WUHnT96UP6Dquwc=";
          persistentKeepalive = 30;
        }
      ];
    };
  };
}
