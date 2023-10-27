{ config, pkgs, lib, inputs, ... }:
{

  age.secrets.wireguard-private = {
    file = ../secrets/wireguard-private.age;
  };

  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wg-quick.interfaces = {
    wg0 = {
      listenPort = 51820;
      address = [
        "192.168.2.1/24"
      ];
      peers = [
        {
          allowedIPs = [
            "192.168.2.2/32"
          ];
	  persistentKeepalive = 25;
          endpoint = "192.168.0.6:51820";
          publicKey = "dUBPIEnAiHIZCMjqV0ya8qotN3UnMhlEVyGNQcR3gVI=";
        }
        {
          allowedIPs = [
            "192.168.2.3/32"
          ];
	  persistentKeepalive = 25;
          endpoint = "kopatz.ddns.net:51820";
          publicKey = "Eg5ZS3zN05mJ/gct6wJlwVAHTlXpkhxFfUd7yscANV0=";
        }
      ];
      privateKeyFile = config.age.secrets.wireguard-private.path;
    };
  };
}
