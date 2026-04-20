{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "netbird";
  cfg = config.custom.services.${name};
  baseDir = "/1tbssd/netbird";
  domain = "netbird.kopatz.dev";
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables netbird";
    domain = lib.mkOption {
      type = lib.types.str;
      default = domain;
      description = "Domain for the NetBird management API (e.g. for dashboard and CLI access).";
    };
    baseDir = lib.mkOption {
      type = lib.types.str;
      default = baseDir;
      description = "Base directory for NetBird state and config (e.g. /var/lib/netbird).";
    };
  };

  config = lib.mkIf cfg.enable {

    # Keep the NetBird CLI available for joining/testing clients.
    environment.systemPackages = [ pkgs.netbird ];

    # Run NetBird client daemon on the host as part of declarative config.
    systemd.services.netbird.environment = {
      NB_STATE_DIR = "${cfg.baseDir}/client";
    };

    age.secrets.netbird-conf = {
      file = ../../secrets/netbird-conf.age;
    };
    environment.etc."netbird/config.yaml" = {
      source = config.age.secrets.netbird-conf.path;
      mode = "0400";
    };

    # Run NetBird as a declarative NixOS-managed container service.
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    systemd.tmpfiles.rules = [
      "d ${cfg.baseDir} 0750 root root -"
      "d ${cfg.baseDir}/config 0750 root root -"
      "d ${cfg.baseDir}/dashboard 0750 root root -"
      "d ${cfg.baseDir}/client 0750 root root -"
    ];

    # Declarative auto-connect for the homeserver peer.
    # Put the setup key in /var/lib/secrets/netbird-setup-key (content: key only).
    # systemd.services.netbird-up = {
    #   description = "Bring up NetBird peer from declarative config";
    #   wantedBy = [ "multi-user.target" ];
    #   after = [
    #     "network-online.target"
    #     "netbird.service"
    #   ];
    #   wants = [
    #     "network-online.target"
    #     "netbird.service"
    #   ];
    #   serviceConfig = {
    #     Type = "oneshot";
    #     RemainAfterExit = true;
    #     LoadCredential = [ "setupkey:/var/lib/secrets/netbird-setup-key" ];
    #     ExecStart = pkgs.writeShellScript "netbird-up" ''
    #       set -eu
    #
    #       key_file="/run/credentials/netbird-up.service/setupkey"
    #       if [ ! -s "$key_file" ]; then
    #         echo "netbird setup key missing: $key_file" >&2
    #         exit 1
    #       fi
    #
    #       exec ${pkgs.netbird}/bin/netbird up \
    #         --management-url https://netbird.lotz.zip \
    #         --setup-key "$(cat "$key_file")" \
    #         --hostname homeserver
    #     '';
    #     ExecStop = "${pkgs.netbird}/bin/netbird down";
    #   };
    # };

    virtualisation.oci-containers.containers = {
      netbird-server = {
        image = "netbirdio/netbird-server:latest";
        ports = [
          "127.0.0.1:4003:80/tcp"
          "3478:3478/udp"
        ];
        volumes = [
          "${cfg.baseDir}:/var/lib/netbird"
          "/etc/netbird/config.yaml:/etc/netbird/config.yaml:ro"
        ];
        cmd = [
          "--config"
          "/etc/netbird/config.yaml"
        ];
      };

      netbird-dashboard = {
        image = "netbirdio/dashboard:latest";
        ports = [ "127.0.0.1:4004:80/tcp" ];
        volumes = [
          # Optional dashboard overrides (env/js). Keep directory for future use.
          "${cfg.baseDir}/dashboard:/app/data"
        ];
        environment = {
          NETBIRD_MGMT_API_ENDPOINT = "https://${cfg.domain}";
          NETBIRD_MGMT_GRPC_API_ENDPOINT = "https://${cfg.domain}";
          AUTH_AUDIENCE = "netbird-dashboard";
          AUTH_CLIENT_ID = "netbird-dashboard";
          AUTH_CLIENT_SECRET = "";
          AUTH_AUTHORITY = "https://${cfg.domain}/oauth2";
          USE_AUTH0 = "false";
          AUTH_SUPPORTED_SCOPES = "openid profile email groups";
          AUTH_REDIRECT_URI = "/nb-auth";
          AUTH_SILENT_REDIRECT_URI = "/nb-silent-auth";
        };
      };
    };

    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      quic = true;
      http3 = true;
      extraConfig = ''
        # Required for long-lived gRPC/WebSocket connections.
        client_header_timeout 1d;
        client_body_timeout 1d;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Scheme $scheme;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Host $host;
        grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        location ~ ^/(relay|ws-proxy/) {
          proxy_pass http://127.0.0.1:4003;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "Upgrade";
          proxy_set_header Host $host;
          proxy_read_timeout 1d;
        }

        location ~ ^/(signalexchange\.SignalExchange|management\.ManagementService|management\.ProxyService)/ {
          grpc_pass grpc://127.0.0.1:4003;
          grpc_read_timeout 1d;
          grpc_send_timeout 1d;
          grpc_socket_keepalive on;
        }

        location ~ ^/(api|oauth2)/ {
          proxy_pass http://127.0.0.1:4003;
          proxy_set_header Host $host;
        }

        location / {
          proxy_pass http://127.0.0.1:4004;
        }
      '';
    };
  };
}
