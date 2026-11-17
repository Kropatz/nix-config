{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.services;
in
{
  imports = [
    ./acme-cloudflare.nix
    ./adguard.nix
    ./audit.nix
    ./caldav.nix
    ./clamav.nix
    ./dnsmasq.nix
    ./ente.nix
    ./fileshelter.nix
    ./games
    ./gitea-runner.nix
    ./gitea.nix
    ./github-runner.nix
    ./kavita-gitea-runner.nix
    ./kavita.nix
    ./kop-fileshare.nix
    ./kop-monitor.nix
    ./kop-pvlog.nix
    ./kop-sanitizer-bot.nix
    ./kubernetes.nix
    ./nginx.nix
    ./openobserve.nix
    ./suricata.nix
    ./opensnitch.nix
    ./smartd.nix
    ./smartd-exporter.nix
    ./syncthing.nix
    ./wireguard.nix
    ./netbird.nix
    ./netbird-client.nix
    ./transmission.nix
    ./qbittorrent.nix
    ./dtrack.nix
    ./ssh.nix
    ./node-exporter.nix
    ./fail2ban.nix
    ./step-ca.nix
    ./blocklist.nix
    ./coturn.nix
    ./grafana.nix
    ./grafana-log-agent.nix
    ./tdata.nix
    ./samba.nix
    ./netbird-native.nix
    ./kop-service-dashboard.nix
    ./scheibnmeister.nix
  ];

  config = lib.mkMerge [
    (lib.mkIf cfg.acme.enable {
      security.acme = {
        acceptTerms = true;
        defaults.email = "7265381+Kropatz@users.noreply.github.com";
      };
    })
    (lib.mkIf cfg.ddclient-cloudflare.enable {
      age.secrets.cloudflare-api = {
        file = ../../../../secrets/cloudflare-api.age;
      };
      services.ddclient = {
        enable = true;
        domains = [ "kopatz.dev" ];
        protocol = "cloudflare";
        zone = "kopatz.dev";
        ssl = true;
        passwordFile = config.age.secrets."cloudflare-api".path;
        usev6 = "disabled";
      };
      systemd.services.ddclient.after = [ "nss-user-lookup.target" ];
    })
    # configure git clone gitolite@server:gitolite-admin
    # help ssh gitolite@server help
    (lib.mkIf cfg.gitolite.enable {
      services.gitolite = {
        enable = true;
        adminPubkey = config.mainUser.sshKey;
      };
    })
    (lib.mkIf cfg.jellyfin.enable {
      users.users.jellyfin.extraGroups = [ "transmission" ];
      services.jellyfin = {
        enable = true;
      };
    })
    (lib.mkIf cfg.searxng.enable {
      age.secrets.searxng-secrets = {
        file = ../../../../secrets/searxng-secrets.age;
      };
      networking.firewall.allowedTCPPorts = [ 8787 ];
      services.searx = {
        enable = true;
        environmentFile = config.age.secrets."searxng-secrets".path;
        settings = {
          use_default_settings = true;
          server = {
            port = 8787;
            bind_address = "0.0.0.0";
            secret_key = "1";
          };
          search = {
            formats = [
              "json"
              "html"
            ];
            favicon_resolver = "duckduckgo";
          };
        };
      };
    })
  ];
}
