{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.custom.services.nginx;
in
{
  options.custom.services.nginx = {
      enable = mkEnableOption "Enables nginx";
      https = mkOption {
        type = types.bool;
        default = true;
        description = "Should it use https?";
      };
  };
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    networking.firewall.allowedUDPPorts = [ 80 443 ];

    systemd.tmpfiles.rules = [
      "d /data 0770 github-actions-runner nginx -"
      "d /data/website 0770 github-actions-runner nginx -"
    ];

    services.nginx = {
      enable = true;
      package = pkgs.nginxQuic;
      additionalModules = [ pkgs.nginxModules.moreheaders ];

      # Use recommended settings
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      statusPage = lib.mkIf config.services.prometheus.exporters.nginx.enable true;

      # Only allow PFS-enabled ciphers with AES256
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

      appendHttpConfig= ''
          more_set_headers 'Strict-Transport-Security: max-age=31536000; includeSubDomains';
          more_set_headers 'X-XSS-Protection 1; mode=block';
          #  add_header X-Frame-Options 'ALLOW-FROM kopatz.ddns.net';
          more_set_headers 'X-Content-Type-Options nosniff';
          more_set_headers "Content-Security-Policy: frame-ancestors https://kopatz.ddns.net";
          more_set_headers "Referrer-Policy: same-origin";
          more_set_headers "Permissions-Policy: geolocation=(), microphone=()";
      '';

      virtualHosts = {
        "kopatz.ddns.net" = {
          #serverAliases = [
          #    "www.kopatz.ddns.net"
          #    "server.home"
          #    "server.home.arpa"
          #    "192.168.0.6"
          #];
          root = "/data/website";
          forceSSL = cfg.https;
          enableACME = cfg.https;
          quic = cfg.https;
          http3 = cfg.https;
          locations."~* \\.(jpg|png)$".extraConfig= ''
            add_header Access-Control-Allow-Origin *;
          '';
          locations."~ ^/(stash|resources|css)".extraConfig=''
            client_max_body_size    5000M;
            proxy_redirect          off;
            proxy_set_header        Host $host;
            proxy_set_header        X-Real-IP $remote_addr;
            proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header        X-Forwarded-Proto $scheme;
            proxy_set_header        X-NginX-Proxy true;
            proxy_pass http://localhost:5091;
          '';
          locations."/tracker-site" = {
            tryFiles = "$uri $uri/ /tracker-site/index.html =404";
          };
          locations."/tracker-site/api" = {
            extraConfig =''
              rewrite /tracker-site/api/(.*) /$1 break;
            '';
            proxyPass = "http://127.0.0.1:8080";
          };
        };
        #discord bot for tracking useractivity public version 
        "activitytracker.site" = {
          #serverAliases = [
          #     "localhost"
          #]; 
          root = "/data/website/tracker-site-public";
          forceSSL = cfg.https;
          enableACME = cfg.https;
          quic = cfg.https;
          http3 = cfg.https;
          locations."/" = {
            tryFiles = "$uri $uri/ /index.html =404";
          };
          locations."/api" = {
            extraConfig =''
                rewrite /api/(.*) /$1 break;
            '';
            proxyPass = "http://127.0.0.1:8081";
          };
        };
        "adguard.home.arpa" = {
          locations."/".proxyPass = "http://127.0.0.1:3000";
        }; 
      };
    };
  };
}
