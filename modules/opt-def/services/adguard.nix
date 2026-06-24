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
    # acme-url = lib.mkOption {
    #   type = lib.types.str;
    #   default = "https://127.0.0.1:8443/acme/kop-acme/directory";
    #   description = "acme url for the adguard instance";
    # };
    rewrites = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.str);
      default = [
        {
          "domain" = "kopatz.ddns.net";
          "answer" = ip;
        }
        {
          "domain" = "kopatz.dev";
          "answer" = ip;
        }
        {
          "domain" = "git.kopatz.dev";
          "answer" = ip;
        }
        {
          "domain" = "kavita.kopatz.dev";
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
          "domain" = "${cfg.fqdn}";
          "answer" = ip;
        }
        {
          "domain" = "nextcloud.home.arpa";
          "answer" = ip;
        }
        {
          "domain" = "grafana.kopatz.dev";
          "answer" = ip;
        }
        {
          "domain" = "yt.home.arpa";
          "answer" = ip;
        }
        {
          "domain" = "pvlog.kopatz.dev";
          "answer" = ip;
        }
        {
          "domain" = "service-dashboard.kopatz.dev";
          "answer" = ip;
        }
        {
          "domain" = "netbird.kopatz.dev";
          "answer" = ip;
        }
        {
          "domain" = "jellyfin.kopatz.dev";
          "answer" = ip;
        }
        {
          "domain" = "dtrack.kopatz.dev";
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
          "domain" = "tdata.kopatz.dev";
          "answer" = ip;
        }
        {
          "domain" = "tui.kopatz.dev";
          "answer" = ip;
        }
        {
          "domain" = "exposedvm.kopatz.dev";
          "answer" = config.custom.vars.exposedServerIp;
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
      description = "list of domains to rewrite to this server's ip";
    };
  };
}
