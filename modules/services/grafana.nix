{pkgs, config, lib, ...}:
let
  useHttps = config.services.step-ca.enable;
  fqdn = "grafana.home.arpa";
in
{
  services.grafana = {
    enable = true;
    settings.server = {
      domain = fqdn;
      http_port = 2342;
      http_addr = "127.0.0.1";
    };
  };

  systemd.services.grafana = {
    after = [ "step-ca.service" ];
  };

  security.acme.certs."${fqdn}".server = "https://127.0.0.1:8443/acme/acme/directory";
  # nginx reverse proxy
  services.nginx.virtualHosts.${fqdn} = {
    forceSSL = useHttps;
    enableACME = useHttps;
    quic = useHttps;
    http3 = useHttps;
    locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
    scrapeConfigs = [
      {
        job_name = "scrapema";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
    ];
  };
}
