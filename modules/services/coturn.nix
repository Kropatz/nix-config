{ config, pkgs, lib, inputs, ... }:
{
  age.secrets.coturn-secret = {
    file = ../../secrets/coturn-secret.age;
    owner = "turnserver";
    group = "turnserver";
  };

  networking.firewall.allowedUDPPortRanges = [{ from = 49000; to = 50000; }];
  networking.firewall.allowedUDPPorts = [ 3478 ]; #5349 ];
  networking.firewall.allowedTCPPorts = [ 3478 ]; #5349 ];


  services.coturn = {
    enable = true;
    no-cli = true;
    #tls-listening-port = 5349;
    listening-port = 3478;
    min-port = 49000;
    max-port = 50000;
    use-auth-secret = true;
    static-auth-secret-file = config.age.secrets.coturn-secret.path;
    relay-ips = [
      "192.168.2.1"
    ];
    listening-ips = [
      "192.168.2.1"
    ];
    realm = "kopatz.ddns.net";
    #cert = "${config.security.acme.certs."kopatz.ddns.net".directory}/full.pem";
    #pkey = "${config.security.acme.certs."kopatz.ddns.net".directory}/key.pem";
    extraConfig = ''
      no-sslv3
      no-tlsv1
      no-tlsv1_1
      no-tlsv1_2
      # for debugging
      verbose
      # ban private IP ranges
      no-multicast-peers
      allowed-peer-ip=192.168.2.0-192.168.2.255
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255
      denied-peer-ip=::1
      denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
      denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
      denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
      denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    '';
  };

  #systemd.services.coturn = {
  #	serviceConfig = {
  #	  User = lib.mkForce "root";
  #	  Group = lib.mkForce "root";
  #	};	 
  #  };
}
