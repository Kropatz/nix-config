{ config, pkgs, lib, inputs, vars, ... }:
let
  wireguardIp = vars.wireguardIp;
  fqdn = "nextcloud.home.arpa";
  useHttps = config.services.step-ca.enable;
in
{
    security.acme.certs."${fqdn}".server = "https://127.0.0.1:8443/acme/acme/directory";
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
            "${fqdn}" = {
              serverAliases = [ wireguardIp ];
                ## Force HTTP redirect to HTTPS
                forceSSL = useHttps;
                enableACME = useHttps;
                locations."~ \\.php(?:$|/)".extraConfig = ''
                  client_max_body_size 20G;
                '';
            };
        };
    };

    age.secrets.nextcloud-admin = {
        file = ../../secrets/nextcloud-admin.age;
        owner = "nextcloud";
        group = "nextcloud";
    };
    services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud28;
        https = true;
        hostName = "nextcloud.home.arpa";
        config.adminpassFile = config.age.secrets.nextcloud-admin.path;
        config.dbtype = "pgsql";
        database.createLocally = true;
        settings.trusted_domains = [ wireguardIp "nextcloud.home.arpa" ];
        home = "/mnt/250ssd/nextcloud";
        extraApps = with config.services.nextcloud.package.packages.apps; {
            inherit onlyoffice calendar mail;
        };

        phpOptions = {
          upload_max_filesize = lib.mkForce "20G";
          post_max_size = lib.mkForce "20G";
        };
        extraAppsEnable = true;
        settings.enabledPreviewProviders = [
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
