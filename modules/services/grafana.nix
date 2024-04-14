{pkgs, config, lib, ...}:
let
  useHttps = config.services.step-ca.enable;
  fqdn = "grafana.home.arpa";
in
{
  age.secrets.grafana-contact-points = {
    name = "contact-points.yml";
    owner = "grafana";
    file = ../../secrets/grafana-contact-points.age;
  };

  services.grafana = {
    enable = true;
    settings.server = {
      domain = fqdn;
      http_port = 2342;
      http_addr = "127.0.0.1";
    };

    provision.alerting.contactPoints.path = config.age.secrets.grafana-contact-points.path;
    provision.alerting.policies.path = ./grafana/notification-policies.yml; 
    provision.alerting.templates.path = ./grafana/alerts.yml;
    provision.datasources.settings = {
     datasources =
       [
         {
           name = "DS_PROMETHEUS";
           url = "http://127.0.0.1:${toString config.services.prometheus.port}";
           type = "prometheus";
           isDefault = true;
         }
       ];
    };
    provision.dashboards.settings.providers = [{
      name = "provisioned-dashboards";
      options.path = ./grafana/dashboards;
    }];
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
    port = 9000;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9001;
      };
    };
    scrapeConfigs = [
      {
        job_name = "scrapema";
        static_configs = [{
          targets = [ 
          "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" 
          ] ++ (lib.optional config.services.cadvisor.enable "${config.services.cadvisor.listenAddress}:${toString config.services.cadvisor.port}");
        }]; 
      }
    ];
  };
  
  services.cadvisor = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9002;
  };

  #virtualisation.docker.daemon.settings = lib.mkIf (config.virtualisation.docker.enable && config.services.prometheus.enable) {
  #  metrics-addr = "127.0.0.1:9323";
  #  experimental = true;
  #};

  # Logs
  services.loki = {
    enable = true;
    dataDir = "/mnt/250ssd/loki";
    configFile = ./grafana/loki.yml;
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 28183;
        grpc_listen_port = 0;
        log_level = "warn";
      };
      positions.filename = "/tmp/positions.yaml";
      clients = [
        { url = "http://127.0.0.1:3100/loki/api/v1/push"; }
      ];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "24h";
            labels = {
              job = "systemd-journal";
              host = "127.0.0.1";
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
          ];
        }
      ];
    };
  };
}
