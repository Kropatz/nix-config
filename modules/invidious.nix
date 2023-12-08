{ config, vars, ...} :
let
  fqdn = "yt.home.arpa";
  useHttps = config.services.step-ca.enable;
in
{
  age.secrets.invidious-extra-settings = {
    file = ../secrets/invidious-extra-settings.age;
    mode = "444";
  };

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
      external_port = if useHttps then 443 else 80;
      https_only = useHttps;

      use_quic = useHttps;

      statistics_enabled = false;

      registration_enabled = true;
      login_enabled = true;
      captcha_enabled = false;
      admins = [ ];

      use_pubsub_feeds = false;
      channel_refresh_interval = "15m";
      dark_mode = "dark";
      autoplay = true;
    };

    extraSettingsFile = config.age.secrets.invidious-extra-settings.path;

    nginx.enable = false;
  };

  security.acme.certs."${fqdn}".server = "https://127.0.0.1:8443/acme/acme/directory";
  services.nginx.virtualHosts."${fqdn}" = {
    forceSSL = useHttps;
    enableACME = useHttps;
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:8007";
    };
  };
}
