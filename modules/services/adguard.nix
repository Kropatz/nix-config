{ config, pkgs, inputs, lib, ... }:
let cfg = config.custom.services.adguard;
in {
  options.custom.services.adguard = {
    enable = lib.mkEnableOption "Enables adguard";
    ip = lib.mkOption {
      type = lib.types.str;
      default = config.custom.static-ip.ip;
      description = "this servers ipv4 address";
    };
    fqdn = lib.mkOption {
      type = lib.types.str;
      default = "adguard.home.arpa";
      description = "fqdn for the adguard instance";
    };
    useHttps = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "use https for the adguard instance";
    };
    acme-url = lib.mkOption {
      type = lib.types.str;
      default = "https://127.0.0.1:8443/acme/kop-acme/directory";
      description = "acme url for the adguard instance";
    };
  };
  config =
    let
      ip = cfg.ip;
      wireguardIp = config.custom.services.wireguard.ip;
    in
    lib.mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = [ 53 ];
      networking.firewall.allowedUDPPorts = [ 53 ];

      security.acme.certs."${cfg.fqdn}".server = cfg.acme-url;
      # nginx reverse proxy
      services.nginx.enable = true;
      services.nginx.virtualHosts.${cfg.fqdn} = {
        forceSSL = cfg.useHttps;
        enableACME = cfg.useHttps;
        locations."/" = {
          proxyPass =
            "http://127.0.0.1:${toString config.services.adguardhome.port}";
          proxyWebsockets = true;
        };
      };
      systemd.services.adguardhome = {
        after = [ "nginx.service" "step-ca.service" ];
      };

      services.adguardhome = {
        enable = true;
        settings = {
          schema_version = 28;
          users = [{
            name = "admin";
            password =
              "$2y$15$iPzjmUJPTwWUOsDp46GOPO/LYor/jDJjndwy2QlPddaKSD4QXvq9W";
          }];
          dns = {
            bind_hosts = [ "127.0.0.1" ip ] ++ lib.lists.optionals config.custom.services.wireguard.enable [ wireguardIp ];
            port = 53;
            protection_enabled = true;
            filtering_enabled = true;
            upstream_dns = [
              "https://dns10.quad9.net/dns-query"
              "https://dns.adguard-dns.com/dns-query"
              "https://noads.joindns4.eu/dns-query"
              "tls://getdnsapi.net"
            ];
            fallback_dns = [
              "1.1.1.1"
              "1.0.0.1"
            ];
            use_http3_upstreams = true;
          };
          querylog = { enabled = false; };
          filters = [
            {
              enabled = true;
              url =
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
              name = "adguard dns list";
              id = 1;
            }
            {
              enabled = true;
              url =
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
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
          tls = { enabled = false; };
          filtering = {
            rewrites = [
              {
                "domain" = "kopatz.ddns.net";
                "answer" = ip;
              }
              {
                "domain" = "kop.oasch.net";
                "answer" = ip;
              }
              {
                "domain" = "kop.bobin.at";
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
                "domain" = "powerline.home.arpa";
                "answer" = "192.168.0.2";
              }
              {
                "domain" = "3neo.home.arpa";
                "answer" = "192.168.0.4";
              }
              {
                "domain" = "alcatel.home.arpa";
                "answer" = "192.168.0.5";
              }
              {
                "domain" = "extender.home.arpa";
                "answer" = "192.168.0.8";
              }
              {
                "domain" = "inverter.home.arpa";
                "answer" = "192.168.0.9";
              }
            ];
          };
        };
      };
    };
}
