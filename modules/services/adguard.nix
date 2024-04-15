{ config, pkgs, inputs, vars, ... }:
let 
  ip = vars.ipv4;
  wireguardIp = vars.wireguardIp;
in
{
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.adguardhome = {
    enable = true;
    settings = {
      schema_version = 20;
      users = [
        {
          name = "admin";
          password = "$2y$15$iPzjmUJPTwWUOsDp46GOPO/LYor/jDJjndwy2QlPddaKSD4QXvq9W";
        }
      ];
      dns = {
        bind_hosts = [ "127.0.0.1" ip wireguardIp ];
        port = 53;
        protection_enabled = true;
        filtering_enabled = true;
        upstream_dns = [ 
          "https://doh.tiar.app/dns-query"
          "tls://getdnsapi.net"
          "https://dns.adguard-dns.com/dns-query"
          "tls://dot.seby.io"
        ];
        use_http3_upstreams = true;
        rewrites = [
         {
          "domain" = "kopatz.ddns.net";
          "answer" = ip;
         }
         {
          "domain" = "kavita-kopatz.duckdns.org";
          "answer" = ip;
         }
         {
          "domain" = "server.home";
          "answer" = ip;
         }
         {
          "domain" = "server.home.arpa";
          "answer" = ip;
         }
         {
          "domain" = "activitytracker.site";
          "answer" = ip;
         }
         {
          "domain" = "adguard.home.arpa";
          "answer" = ip;
         }
         {
          "domain" = "nextcloud.home.arpa";
          "answer" = ip;
         }
         {
          "domain" = "kavita.home.arpa";
          "answer" = ip;
         }
         {
          "domain" = "grafana.home.arpa";
          "answer" = ip;
         }
         {
          "domain" = "yt.home.arpa";
          "answer" = ip;
         }
         {
          "domain" = "nextcloud.home.arpa";
          "answer" = wireguardIp;
         }
         {
          "domain" = "kavita.home.arpa";
          "answer" = wireguardIp;
         }
         {
          "domain" = "yt.home.arpa";
          "answer" = wireguardIp;
         }
         {
           "domain" = "turnserver.home.arpa";
           "answer" = wireguardIp;
         }
         {
          "domain" = "inverter.home.arpa";
          "answer" = "192.168.0.9";
         }
        ];
      };
      querylog = {
        enabled = false;
      };
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "adguard dns list";
          id = 1;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          name = "adguard block list";
          id = 2;
        }
        {
          enabled = true;
          url = "https://dbl.oisd.nl/";
          name = "big block list";
          id = 3;
        }
      ];
      dhcp = { enabled = false; };
      dhcpv6 = { enabled = false; };
      tls = {
        enabled = true;
      };
    };
  };
}
