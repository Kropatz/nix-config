{ config, pkgs, lib, inputs, ... }:
{
    age.secrets.nextcloud-cert = {
        file = ../secrets/nextcloud-cert.age;
        owner = "nginx";
        group = "nginx";
    };
    age.secrets.nextcloud-key = {
        file = ../secrets/nextcloud-key.age;
        owner = "nginx";
        group = "nginx";
    };
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
            "nextcloud.local" = {
		serverAliases = [ "192.168.2.1" ];
                ## Force HTTP redirect to HTTPS
                forceSSL = true;
		locations."~ ^\\/(?:index|remote|public|cron|core\\/ajax\\/update|status|ocs\\/v[12]|updater\\/.+|oc[s]-provider\\/.+|.+\\/richdocumentscode\\/proxy)\\.php(?:$|\\/)".extraConfig = ''
			client_max_body_size 5G;
		'';
	        #sslTrustedCertificate = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
	        sslCertificate = config.age.secrets.nextcloud-cert.path;
	        sslCertificateKey = config.age.secrets.nextcloud-key.path;
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
	https = true;
        hostName = "nextcloud.local";
        config.adminpassFile = config.age.secrets.nextcloud-admin.path;
	config.dbtype = "pgsql";
	database.createLocally = true;
	config.extraTrustedDomains = [ "192.168.2.1" ];
        home = "/mnt/250ssd/nextcloud";

        extraApps = {
            spreed = pkgs.fetchNextcloudApp rec {
                url = "https://github.com/nextcloud-releases/spreed/releases/download/v17.1.1/spreed-v17.1.1.tar.gz";
                sha256 = "sha256-LaUG0maatc2YtWQjff7J54vadQ2RE4X6FcW8vFefBh8=";
            };
        };

  	phpOptions = {
    		upload_max_filesize = "5G";
    		post_max_size = "5G";
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
