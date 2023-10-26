{ config, pkgs, lib, inputs, ... }:
{
        # Enable Nginx
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
            "localhost" = {
                ## Force HTTP redirect to HTTPS
                #forceSSL = true;
                ## LetsEncrypt
                #enableACME = true;
            };
        };
    };


    age.secrets.nextcloud-admin = {
        file = ../secrets/nextcloud-admin.age;
        owner = "nextcloud";
        group = "nextcloud";
    };
    services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud27;
        hostName = "localhost";
        config.adminpassFile = config.age.secrets.nextcloud-admin.path;

        home = "/var/lib/nextcloud";

        extraApps = {
            spreed = pkgs.fetchNextcloudApp rec {
                url = "https://github.com/nextcloud-releases/spreed/releases/download/v17.1.1/spreed-v17.1.1.tar.gz";
                sha256 = "sha256-LaUG0maatc2YtWQjff7J54vadQ2RE4X6FcW8vFefBh8=";
            };
        };
        extraAppsEnable = true;
        extraOptions.enabledPreviewProviders = [
            "OC\\Preview\\BMP"
            "OC\\Preview\\GIF"
            "OC\\Preview\\JPEG"
            "OC\\Preview\\Krita"
            "OC\\Preview\\MarkDown"
            "OC\\Preview\\MP3"
            "OC\\Preview\\OpenDocument"
            "OC\\Preview\\PNG"
            "OC\\Preview\\TXT"
            "OC\\Preview\\XBitmap"
            "OC\\Preview\\HEIC"
        ];
    };
}