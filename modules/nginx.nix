{
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    systemd.tmpfiles.rules = [
        "d /data 0770 github-actions-runner nginx -"
        "d /data/website 0770 github-actions-runner nginx -"
    ];

    services.nginx = {
        enable = true;

        # Use recommended settings
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;

        # Only allow PFS-enabled ciphers with AES256
            sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

        # Setup Nextcloud virtual host to listen on ports
        virtualHosts = {
            "kopatz.ddns.net" = {
                #serverAliases = [
                #    "www.kopatz.ddns.net"
                #    "server.home"
                #    "server.local"
                #    "192.168.0.6"
                #];
                root = "/data/website";
                forceSSL = true;
                enableACME = true;
                locations."~* \\.(jpg)$".extraConfig= ''
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
 
 	       #locations."~/books(.*)$" = {
               #    proxyPass = "http://127.0.0.1:5000";
               #};
            },
            #discord bot for tracking useractivity public version 
            "activitytracker.site" = {
                root = "/data/website";
                forceSSL = true;
                enableACME = true;
                locations."~* \\.(jpg)$".extraConfig= ''
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
                	proxy_pass http://localhost:5092;
                '';
		        locations."/" = {
			        tryFiles = "$uri $uri/ /tracker-site/index.html =404";
		        };
                locations."/api" = {
                    extraConfig =''
                        rewrite /api/(.*) /$1 break;
                    '';
                    proxyPass = "http://127.0.0.1:8080";
                };
           };
            "adguard.local" = {
                locations."/".proxyPass = "http://127.0.0.1:3000";
            }; 
        };
    };
}
