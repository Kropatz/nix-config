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
	{
          allowedIPs = [
            "192.168.2.4/32"
          ];
	  persistentKeepalive = 25;
          endpoint = "kopatz.ddns.net:51820";
          publicKey = "8Eigfs+k2k2WPaMn+SqDmlSHdMv+I+xcBr/2qhtpGzI=";
        }

	{
          allowedIPs = [
            "192.168.2.20/32"
          ];
	  persistentKeepalive = 25;
          endpoint = "kopatz.ddns.net:51820";
          publicKey = "25u1RSfjsx3wb1DMeTm0pvUfUkG7zTjGaN+m0w6ZjCw=";
        }
	{
          allowedIPs = [
            "192.168.2.21/32"
          ];
	  persistentKeepalive = 25;
          endpoint = "kopatz.ddns.net:51820";
          publicKey = "S+8F+yxSQvjjoU44LRYqRv1YulqmOKumUtYo/YIh7X8=";
        }
	{
          allowedIPs = [
            "192.168.2.22/32"
          ];
	  persistentKeepalive = 25;
          endpoint = "kopatz.ddns.net:51820";
          publicKey = "/dIW7K49vB9HOghFeXvcY7wu2utQltuv6RfgCbxZwlk=";
        }
	{
          allowedIPs = [
            "192.168.2.23/32"
          ];
	  persistentKeepalive = 25;
          endpoint = "kopatz.ddns.net:51820";
          publicKey = "89rjQXNcyCRUCihqfqcOnctWmhiNR8snpRFF6dyHAmk=";
        }
	{
          allowedIPs = [
            "192.168.2.24/32"
          ];
	  persistentKeepalive = 25;
          endpoint = "kopatz.ddns.net:51820";
          publicKey = "adaWtboVz3UhpNBKFirs7slbU2+Y3GaV5yS2EoafwVU=";
        }
	
      ];
      privateKeyFile = config.age.secrets.wireguard-private.path;
    };
  };
}
