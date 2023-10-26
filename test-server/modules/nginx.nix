{
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
                serverAliases = [
                    "www.kopatz.ddns.net"
                    "server.home"
                    "server.local"
                    "192.168.0.6"
                ];
                root = "/var/www";
                #forceSSL = true;
                #enableACME = true;
                locations."~* \\.(jpg)$".extraConfig= ''
                    add_header Access-Control-Allow-Origin *;
                '';
            };
        };
    };
}