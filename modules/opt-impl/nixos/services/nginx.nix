{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.nginx;
in
{
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [
      80
      443
    ];

    age.secrets.stash-auth = {
      file = ../../../../secrets/stash-auth.age;
      owner = "nginx";
    };

    systemd.tmpfiles.rules = [
      "d /var/www 0740 nginx nginx -"
      "d /var/www/misc-files 0740 nginx nginx -"
    ]
    ++ lib.optionals cfg.dav [
      "d /hdd/nginx 0740 nginx nginx -"
      "d /hdd/nginx/dav 0740 nginx nginx -"
      "d /hdd/nginx/dav-tmp 0740 nginx nginx -"
    ];

    systemd.services.nginx = lib.mkIf cfg.dav {
      serviceConfig = {
        BindPaths = [ "/hdd/nginx" ];
      };
    };

    services.nginx = {
      enable = true;
      additionalModules =
        with pkgs.nginxModules;
        [
          moreheaders
          fancyindex
        ]
        ++ lib.optionals cfg.dav [
          dav
        ];

      # Use recommended settings
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      statusPage = lib.mkIf config.services.prometheus.exporters.nginx.enable true;

      # Only allow PFS-enabled ciphers with AES256
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

      appendHttpConfig = ''
        more_set_headers 'Strict-Transport-Security: max-age=31536000; includeSubDomains';
        more_set_headers 'X-XSS-Protection 1; mode=block';
        #  add_header X-Frame-Options 'ALLOW-FROM kopatz.ddns.net';
        more_set_headers 'X-Content-Type-Options nosniff';
        more_set_headers "Content-Security-Policy: frame-ancestors https://kop.oasch.net https://kopatz.dev";
        more_set_headers "Referrer-Policy: same-origin";
        more_set_headers "Permissions-Policy: geolocation=(), microphone=()";
      '';

      virtualHosts =
        let
          kopConfig = domain: {
            root = pkgs.kop-website;
            forceSSL = cfg.https;
            enableACME = cfg.https;
            acmeRoot =
              if domain == "kopatz.dev" || domain == "www.kopatz.dev" then
                null
              else
                "/var/lib/acme/acme-challenge";
            quic = cfg.https;
            http3 = cfg.https;
            locations = {
              "~* ^/assets/.*\\.(jpg|png)$".extraConfig = ''
                add_header Access-Control-Allow-Origin *;
              '';
              "/stash" = {
                basicAuthFile = config.age.secrets.stash-auth.path;
                extraConfig = ''
                  client_max_body_size    20000M;
                  proxy_redirect          off;
                  proxy_set_header        Host $host;
                  proxy_set_header        X-Real-IP $remote_addr;
                  proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header        X-Forwarded-Proto $scheme;
                  proxy_set_header        X-NginX-Proxy true;
                  proxy_pass http://${config.custom.vars.exposedServerIp}:7777;
                '';
              };
              "/stash/upload" = {
                basicAuthFile = config.age.secrets.stash-auth.path;
                extraConfig = ''
                  more_set_headers       "Access-Control-Allow-Origin: null";
                  more_set_headers       "Access-Control-Allow-Methods: POST, OPTIONS";
                  more_set_headers       "Access-Control-Allow-Headers: Authorization, Content-Type";
                  more_set_headers       "Access-Control-Allow-Credentials: true";
                  more_set_headers       "Vary: Origin";
                  if ($request_method = OPTIONS) {
                    return 204;
                  }
                  client_max_body_size    20000M;
                  proxy_redirect          off;
                  proxy_set_header        Host $host;
                  proxy_set_header        X-Real-IP $remote_addr;
                  proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header        X-Forwarded-Proto $scheme;
                  proxy_set_header        X-NginX-Proxy true;
                  proxy_pass http://${config.custom.vars.exposedServerIp}:7777;
                '';
              };
              "/stash/files" = {
                extraConfig = ''
                  proxy_redirect          off;
                  proxy_set_header        Host $host;
                  proxy_set_header        X-Real-IP $remote_addr;
                  proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header        X-Forwarded-Proto $scheme;
                  proxy_set_header        X-NginX-Proxy true;
                  proxy_pass http://${config.custom.vars.exposedServerIp}:7777;
                '';
              };
              "/tracker-site" = {
                tryFiles = "$uri $uri/ /tracker-site/index.html =404";
              };
              "/tracker-site/api" = {
                extraConfig = ''
                  rewrite /tracker-site/api/(.*) /$1 break;
                '';
                proxyPass = "http://192.168.0.22:8081";
              };
              "/radicale/" = {
                extraConfig = ''
                  proxy_set_header  X-Script-Name /radicale;
                '';
                proxyPass = "http://localhost:5232/";
              };
              "/socket.io" = {
                proxyPass = "http://localhost:9955";
                proxyWebsockets = true;
              };
              "/comms/" = {
                extraConfig = ''
                  more_set_headers "Permissions-Policy: geolocation=(), microphone=(self), camera=(self)";
                '';
                alias = "/comms/";
                tryFiles = "$uri $uri/ /comms/index.html";
              };
              "/comms" = {
                extraConfig = ''
                  return 301 /comms/;
                '';
              };
              "/kavita-client" = {
                extraConfig = ''
                  return 301 /kavita-client/;
                '';
              };
              "/kavita-client/" = {
                alias = "/kavita-client/";
              };
              "/misc-files/" = {
                alias = "/var/www/misc-files/";
              };
              "/misc-big/" = {
                alias = "/hdd/nginx/misc-big/";
              };
              "/javaland/" = {
                alias = "/var/www/javaland/";
                extraConfig = ''
                  fancyindex on;
                  fancyindex_hide_parent_dir on;
                  fancyindex_exact_size off;
                '';
              };

              "/comms2/api" = {
                extraConfig = ''
                  client_max_body_size    20000M;
                  more_set_headers       "Access-Control-Allow-Origin: app://index";
                  more_set_headers       "Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, PATCH, DELETE";
                  more_set_headers       "Access-Control-Allow-Headers: Authorization, Content-Type";
                  more_set_headers       "Access-Control-Allow-Credentials: true";
                  rewrite /comms2/api/(.*) /$1 break;
                '';
                proxyPass = "http://localhost:3200/";
                proxyWebsockets = true;
              };
              "/comms2" = {
                extraConfig = ''
                  return 301 /comms2/;
                '';
              };
              "/comms2/" = {
                extraConfig = ''
                  more_set_headers "Permissions-Policy: geolocation=(), microphone=(self), camera=(self)";
                '';
                alias = "/var/www/discord-clone/";
                tryFiles = "$uri $uri/ /var/www/discord-clone/index.html";
              };
              "/dav" = lib.mkIf cfg.dav {
                extraConfig = ''
                  root '/hdd/nginx';
                  dav_methods PUT DELETE MKCOL COPY MOVE;
                  dav_ext_methods PROPFIND OPTIONS;
                  # Adjust as desired:
                  dav_access user:rw group:rw;
                  client_max_body_size 0;
                  create_full_put_path on;
                  client_body_temp_path /hdd/nginx/dav-tmp;
                  autoindex on;

                  allow 192.168.0.0/24;
                  allow 192.168.2.0/24;
                  deny all;
                '';
              };
              "/robots.txt" = {
                extraConfig = ''
                  add_header Content-Type text/plain;
                  return 200 "User-agent: *\nDisallow: /\n";
                '';
              };
            };
          };
        in
        {
          "kop.oasch.net" = kopConfig "kop.oasch.net";
          "kop.bobin.at" = kopConfig "kop.bobin.at";
          "kop.detschn.net" = kopConfig "kop.detschn.net";
          "kopatz.dev" = (kopConfig "kopatz.dev") // {
            default = true;
          };
          "kavita.kopatz.dev" = {
            forceSSL = true;
            useACMEHost = "kopatz.dev";
            quic = true;
            http3 = true;
            locations."/".proxyPass = "http://${config.custom.vars.exposedServerIp}:5000";
            locations."/".extraConfig = ''
              more_clear_headers 'x-frame-options';
              add_header Access-Control-Allow-Origin *;
              add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
              add_header Access-Control-Allow-Headers "Authorization, Origin, X-Requested-With, Content-Type, Accept";
            '';
            locations."/robots.txt" = {
              extraConfig = ''
                add_header Content-Type text/plain;
                return 200 "User-agent: *\nDisallow: /\n";
              '';
            };
          };
          "jellyfin.kopatz.dev" = {
            forceSSL = true;
            useACMEHost = "kopatz.dev";
            quic = true;
            http3 = true;
            locations."/".proxyPass = "http://${config.custom.vars.exposedServerIp}:8096";
            locations."/".extraConfig = ''
              more_clear_headers 'x-frame-options';
              add_header Access-Control-Allow-Origin *;
              add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
              add_header Access-Control-Allow-Headers "Authorization, Origin, X-Requested-With, Content-Type, Accept";
            '';
            locations."/robots.txt" = {
              extraConfig = ''
                add_header Content-Type text/plain;
                return 200 "User-agent: *\nDisallow: /\n";
              '';
            };
          };
          "git.kopatz.dev" = {
            forceSSL = true;
            # enableACME = true;
            useACMEHost = "kopatz.dev";
            quic = true;
            http3 = true;
            locations."/".proxyPass = "http://${config.custom.vars.exposedServerIp}:3002";
            locations."/robots.txt" = {
              extraConfig = ''
                add_header Content-Type text/plain;
                return 200 "User-agent: *\nDisallow: /\n";
              '';
            };
          };
          "gitui.kopatz.dev" = {
            forceSSL = true;
            # enableACME = true;
            useACMEHost = "kopatz.dev";
            quic = true;
            http3 = true;
            locations."/".proxyPass = "http://${config.custom.vars.exposedServerIp}:3002";
            locations."/robots.txt" = {
              extraConfig = ''
                add_header Content-Type text/plain;
                return 200 "User-agent: *\nDisallow: /\n";
              '';
            };
          };
        };
    };
  };
}
