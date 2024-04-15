{ pkgs, ... }:
{
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    networking.firewall.allowedUDPPorts = [ 80 443 ];

    systemd.tmpfiles.rules = [
        "d /data 0770 github-actions-runner nginx -"
        "d /data/website 0770 github-actions-runner nginx -"
    ];

    services.nginx = {
        enable = true;
        package = pkgs.nginxQuic;
        #additionalModules = [ pkgs.nginxModules.moreheaders ];

        # Use recommended settings
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;

        # Only allow PFS-enabled ciphers with AES256
        sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

        #appendConfig= ''
        #    more_set_headers 'Strict-Transport-Security: max-age=31536000; includeSubDomains';
        #    more_set_headers 'X-XSS-Protection 1; mode=block';
        #    more_set_headers 'X-Frame-Options SAMEORIGIN';
        #    more_set_headers 'X-Content-Type-Options nosniff';
        #    more_set_headers "Content-Security-Policy default-src 'self'; font-src *;";
        #'';

        appendHttpConfig = ''
          # Add HSTS header with preloading to HTTPS requests.
          # Adding this header to HTTP requests is discouraged
          map $scheme $hsts_header {
              https   "max-age=31536000; includeSubdomains; preload";
          }
          add_header Strict-Transport-Security $hsts_header;

          # Enable CSP for your services.
          add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none'; frame-ancestors 'https://kopatz.ddns.net'" always;

          # Minimize information leaked to other domains
          add_header 'Referrer-Policy' 'origin-when-cross-origin';

          # Disable embedding as a frame
          add_header X-Frame-Options 'ALLOW-FROM kopatz.ddns.net';

          # Prevent injection of code in other mime types (XSS Attacks)
          add_header X-Content-Type-Options nosniff;
        '';

        # Setup Nextcloud virtual host to listen on ports
        virtualHosts = {
            "kopatz.ddns.net" = {
                #serverAliases = [
                #    "www.kopatz.ddns.net"
                #    "server.home"
                #    "server.home.arpa"
                #    "192.168.0.6"
                #];
                root = "/data/website";
                forceSSL = true;
                enableACME = true;
                quic = true;
                http3 = true;
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
                forceSSL = true;
                enableACME = true;
                quic = true;
                http3 = true;
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
}
