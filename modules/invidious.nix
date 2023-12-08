{ config, vars, ...} :
let
  fqdn = "yt.local";
in
{
  services.invidious = {
    enable = true;

    domain = fqdn;
    port = 8007;

    database = {
      createLocally = true;
    };

    settings = {
      db = {
        user = "invidious";
        dbname = "invidious";
      };

      host_binding = "127.0.0.1";
      external_port = 80;
      https_only = false;

      use_quic = false;

      statistics_enabled = false;

      registration_enabled = false;
      login_enabled = true;
      captcha_enabled = false;
      admins = [ ];

      use_pubsub_feeds = false;
      channel_refresh_interval = "15m";
    };

    extraSettingsFile = config.age.secrets.invidious-extra-settings.path;

    nginx.enable = false;
  };

  services.nginx.virtualHosts."${fqdn}" = {
    listenAddresses = [ vars.ipv4 vars.wireguardIp ];

    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:8007";
    };
  };
}
