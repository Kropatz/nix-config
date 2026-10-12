{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  cfg = config.custom.services.adguard;
  ip = cfg.ip;
  wireguardIp = config.custom.services.wireguard.ip;
in
{
  config =
    #let
    #  ip = cfg.ip;
    #  wireguardIp = config.custom.services.wireguard.ip;
    #in
    lib.mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = [ 53 ];
      networking.firewall.allowedUDPPorts = [ 53 ];

      # security.acme.certs."${cfg.fqdn}".server = cfg.acme-url;
      # nginx reverse proxy
      services.nginx.enable = true;
      services.nginx.virtualHosts.${cfg.fqdn} = {
        forceSSL = cfg.useHttps;
        useACMEHost = "kopatz.dev";
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.adguardhome.port}";
          proxyWebsockets = true;
        };
      };
      systemd.services.adguardhome = {
        after = [
          "nginx.service"
          "step-ca.service"
        ];
      };

      services.adguardhome = {
        enable = true;
        settings = {
          schema_version = 28;
          users = [
            {
              name = "admin";
              password = "$2y$15$iPzjmUJPTwWUOsDp46GOPO/LYor/jDJjndwy2QlPddaKSD4QXvq9W";
            }
          ];
          dns = {
            bind_hosts = [
              "127.0.0.1"
              ip
            ]
            ++ lib.lists.optionals config.custom.services.wireguard.enable [ wireguardIp ];
            port = 53;
            protection_enabled = true;
            filtering_enabled = true;
            upstream_dns = [
              #"https://dns10.quad9.net/dns-query" slow
              "quic://dns.adguard-dns.com"
              #"tls://noads.libredns.gr" slow
              "https://noads.joindns4.eu/dns-query"
              #"tls://getdnsapi.net" dead, connection times out
              "https://base.dns.mullvad.net/dns-query"
              "https://dns.quad9.net/dns-query"
            ];
            fallback_dns = [
              "1.1.1.1"
              "1.0.0.1"
            ];
            use_http3_upstreams = true;
            # query all upstreams at once, use the fastest answer
            upstream_mode = "parallel";
            # default 20 qps per client drops queries during page loads
            ratelimit = 0;
            # serve expired cache entries while refreshing in the background
            cache_optimistic = true;
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
          # doesn't work...
          whitelist_filters = [
            {
              enabled = true;
              url = pkgs.writeText "adguard-whitelist.txt" ''
                @@|pool.supportxmr.com^
              '';
              name = "adguard whitelist";
            }
          ];
          dhcp = {
            enabled = false;
          };
          tls = {
            enabled = false;
          };
          filtering = {
            rewrites = cfg.rewrites;
          };
        };
      };
    };
}
