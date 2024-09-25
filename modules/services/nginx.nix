{ config, pkgs, lib, inputs, ... }:
with lib;
let cfg = config.custom.services.nginx;
in {
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

    age.secrets.stash-auth = {
      file = ../../secrets/stash-auth.age;
      owner = "nginx";
    };

    services.nginx = {
      enable = true;
      package = pkgs.nginxQuic;
      additionalModules = [ pkgs.nginxModules.moreheaders ];

      # Use recommended settings
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      statusPage =
        lib.mkIf config.services.prometheus.exporters.nginx.enable true;

      # Only allow PFS-enabled ciphers with AES256
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

      appendHttpConfig = ''
        more_set_headers 'Strict-Transport-Security: max-age=31536000; includeSubDomains';
        more_set_headers 'X-XSS-Protection 1; mode=block';
        #  add_header X-Frame-Options 'ALLOW-FROM kopatz.ddns.net';
        more_set_headers 'X-Content-Type-Options nosniff';
        more_set_headers "Content-Security-Policy: frame-ancestors https://kopatz.ddns.net https://kop.oasch.net";
        more_set_headers "Referrer-Policy: same-origin";
        more_set_headers "Permissions-Policy: geolocation=(), microphone=()";
      '';

      virtualHosts = let
        kopConfig = {
          root = pkgs.kop-website;
          forceSSL = cfg.https;
          enableACME = cfg.https;
          quic = cfg.https;
          http3 = cfg.https;
          locations = {
            "~* \\.(jpg|png)$".extraConfig = ''
              add_header Access-Control-Allow-Origin *;
            '';
            "/stash" = {
              basicAuthFile = config.age.secrets.stash-auth.path;
              extraConfig = ''
                client_max_body_size    5000M;
                proxy_redirect          off;
                proxy_set_header        Host $host;
                proxy_set_header        X-Real-IP $remote_addr;
                proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header        X-Forwarded-Proto $scheme;
                proxy_set_header        X-NginX-Proxy true;
                proxy_pass http://localhost:7777;
              '';
            };
            "/tracker-site" = {
              tryFiles = "$uri $uri/ /tracker-site/index.html =404";
            };
            "/tracker-site/api" = {
              extraConfig = ''
                rewrite /tracker-site/api/(.*) /$1 break;
              '';
              proxyPass = "http://127.0.0.1:8080";
            };
            "/radicale/" = {
              extraConfig = ''
                proxy_set_header  X-Script-Name /radicale;
              '';
              proxyPass = "http://localhost:5232/";
            };
            "/socket.io" = { proxyPass = "http://localhost:9955"; proxyWebsockets = true; };
            "/comms/" = {
              alias = "/comms/";
              tryFiles = "$uri $uri/ /index.html";
            };
          };
        };
      in {
        "kopatz.ddns.net" = kopConfig;
        "kop.oasch.net" = kopConfig;
      };
    };
  };
}
