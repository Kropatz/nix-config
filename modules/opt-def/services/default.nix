{ config, lib, ... }:
let
  adguard = config.custom.services.adguard;
  ip = adguard.ip;
  wireguardIp = config.custom.services.wireguard.ip;
in
{
  imports = [
    ./games
  ];

  options.custom.services = {
    acme.enable = lib.mkEnableOption "Enables acme";
    acme-cloudflare.enable = lib.mkEnableOption "Enables acme-cloudflare";
    adguard = {
      enable = lib.mkEnableOption "Enables adguard";
      ip = lib.mkOption {
        type = lib.types.str;
        default = config.custom.static-ip.ip;
        description = "this servers ipv4 address";
      };
      fqdn = lib.mkOption {
        type = lib.types.str;
        default = "adguard.home.arpa";
        description = "fqdn for the adguard instance";
      };
      useHttps = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "use https for the adguard instance";
      };
      rewrites = lib.mkOption {
        type = lib.types.listOf (lib.types.attrsOf lib.types.str);
        default = [
          {
            "domain" = "kopatz.ddns.net";
            "answer" = ip;
          }
          {
            "domain" = "kopatz.dev";
            "answer" = ip;
          }
          {
            "domain" = "git.kopatz.dev";
            "answer" = ip;
          }
          {
            "domain" = "kavita.kopatz.dev";
            "answer" = ip;
          }
          {
            "domain" = "kop.oasch.net";
            "answer" = ip;
          }
          {
            "domain" = "kop.bobin.at";
            "answer" = ip;
          }
          {
            "domain" = "kavita-kopatz.duckdns.org";
            "answer" = ip;
          }
          {
            "domain" = "server.home";
            "answer" = ip;
          }
          {
            "domain" = "server.home.arpa";
            "answer" = ip;
          }
          {
            "domain" = "${adguard.fqdn}";
            "answer" = ip;
          }
          {
            "domain" = "nextcloud.home.arpa";
            "answer" = ip;
          }
          {
            "domain" = "grafana.kopatz.dev";
            "answer" = ip;
          }
          {
            "domain" = "yt.home.arpa";
            "answer" = ip;
          }
          {
            "domain" = "pvlog.kopatz.dev";
            "answer" = ip;
          }
          {
            "domain" = "service-dashboard.kopatz.dev";
            "answer" = ip;
          }
          {
            "domain" = "netbird.kopatz.dev";
            "answer" = ip;
          }
          {
            "domain" = "jellyfin.kopatz.dev";
            "answer" = ip;
          }
          {
            "domain" = "dtrack.kopatz.dev";
            "answer" = ip;
          }
          {
            "domain" = "nextcloud.home.arpa";
            "answer" = wireguardIp;
          }
          {
            "domain" = "kavita.home.arpa";
            "answer" = wireguardIp;
          }
          {
            "domain" = "yt.home.arpa";
            "answer" = wireguardIp;
          }
          {
            "domain" = "turnserver.home.arpa";
            "answer" = wireguardIp;
          }
          {
            "domain" = "tdata.kopatz.dev";
            "answer" = ip;
          }
          {
            "domain" = "tui.kopatz.dev";
            "answer" = ip;
          }
          {
            "domain" = "exposedvm.kopatz.dev";
            "answer" = config.custom.vars.exposedServerIp;
          }
          {
            "domain" = "powerline.home.arpa";
            "answer" = "192.168.0.2";
          }
          {
            "domain" = "3neo.home.arpa";
            "answer" = "192.168.0.4";
          }
          {
            "domain" = "alcatel.home.arpa";
            "answer" = "192.168.0.5";
          }
          {
            "domain" = "extender.home.arpa";
            "answer" = "192.168.0.8";
          }
          {
            "domain" = "inverter.home.arpa";
            "answer" = "192.168.0.9";
          }
        ];
        description = "list of domains to rewrite to this server's ip";
      };
    };
    blocklist.enable = lib.mkEnableOption "Enables blocklist";
    caldav.enable = lib.mkEnableOption "Enables caldav server";
    clamav = {
      enable = lib.mkEnableOption "Enables clamav";
      enableScanner = lib.mkOption {
        type = with lib.types; bool;
        default = true;
        description = "Enable automatic scanning with clamscan.";
      };
      scanDirectories = lib.mkOption {
        type = with lib.types; listOf str;
        default = [
          "/home"
          "/var/lib"
          "/tmp"
          "/etc"
          "/var/tmp"
        ];
        description = "Directories to scan with clamscan.";
      };
    };
    coturn.enable = lib.mkEnableOption "Enables coturn";
    ddclient-cloudflare.enable = lib.mkEnableOption "Enables ddclient-cloudflare";
    dependency-track.enable = lib.mkEnableOption "Enables depedency-track";
    dnsmasq = {
      enable = lib.mkEnableOption "Enables dnsmaq service";
      server = lib.mkOption { type = lib.types.listOf lib.types.string; };
    };
    ente = {
      enable = lib.mkEnableOption "Enables ente";
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/ente";
        description = "Directory to store uploaded files";
      };
    };
    fail2ban.enable = lib.mkEnableOption "Enables fail2ban";
    fileshelter = {
      enable = lib.mkEnableOption "Enables fileshelter";
      uid = lib.mkOption {
        default = 20000;
        description = "uid of the fileshelter user";
      };
    };
    gitea = {
      enable = lib.mkEnableOption "Enables gitea";
      fqdn = lib.mkOption {
        type = lib.types.str;
        default = "git.kopatz.dev";
        description = "FQDN under which gitea is available";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/1tbssd/gitea";
        description = "Data dir";
      };
      repoDir = lib.mkOption {
        type = lib.types.str;
        default = "${config.custom.services.gitea.dataDir}/repositories";
        description = "Data dir";
      };
      enableNginx = lib.mkEnableOption "Enables nginx reverse proxy for gitea";
    };
    gitea-runner = {
      enable = lib.mkEnableOption "Enables gitea-runner service.";
      workDir = lib.mkOption {
        type = lib.types.str;
        default = "/1tbssd/gitea-actions-runner";
        description = "Directory for gitea runner.";
      };
    };
    github-runner.enable = lib.mkEnableOption "Enables github-runner service.";
    gitolite.enable = lib.mkEnableOption "Enables ente";
    grafana.enable = lib.mkEnableOption "Enables grafana";
    hardening.dataMounts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "-/data"
        "-/1tbssd"
        "-/hdd"
      ];
      description = "Paths to set as InaccessiblePaths. Needs to be paired with SystemCallFilter=~@mount and/or CapabilityBoundingSet=~CAP_SYS_ADMIN.";
    };
    jellyfin.enable = lib.mkEnableOption "Enables jellyfin";
    kavita = {
      enable = lib.mkEnableOption "Enables kavita";
      https = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Should it use https?";
      };
      autoDownload = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Should it auto download?";
      };
      dir = lib.mkOption {
        default = "/data/kavita";
        type = lib.types.path;
        description = "data path";
      };
      isTest = lib.mkEnableOption "Is this a test vm?";
    };
    kavita-gitea-runner = {
      enable = lib.mkEnableOption "Enables kavita runner";
      dir = lib.mkOption {
        default = "/data/shares/exposedvm/kavita";
        type = lib.types.path;
        description = "data path";
      };
    };
    kop-fileshare = {
      enable = lib.mkEnableOption "Enable the file upload server";
      port = lib.mkOption {
        type = lib.types.int;
        default = 7777;
        description = "Port for the file upload server";
      };
      listenAddr = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Listen address for the file upload server";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/file-upload";
        description = "Directory to store uploaded files";
      };
      basePath = lib.mkOption {
        type = lib.types.str;
        default = "/";
        description = "Location under which the file upload server is reachable";
      };
    };
    kop-monitor.enable = lib.mkEnableOption "Enables monitor";
    kop-pvlog = {
      enable = lib.mkEnableOption "Enable the fronius data logger";
      port = lib.mkOption {
        type = lib.types.int;
        default = 7788;
        description = "Port for the fronius data logger";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/pvlog";
        description = "Directory to store the data";
      };
      basePath = lib.mkOption {
        type = lib.types.str;
        default = "/";
        description = "Location under which the data logger is reachable";
      };
      fqdn = lib.mkOption {
        type = lib.types.str;
        default = "pvlog.kopatz.dev";
        description = "FQDN under which the data logger is reachable";
      };
      useStepCa = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Use step-ca for ACME certificates";
      };
    };
    kop-sanitizer-bot.enable = lib.mkEnableOption "Enable the sanitizer bot";
    kop-service-dashboard = {
      enable = lib.mkEnableOption "Enable the service dashboard";
      port = lib.mkOption {
        type = lib.types.int;
        default = config.custom.vars.ports.service-dashboard;
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/service-dashboard";
        description = "Directory to store the data";
      };
      basePath = lib.mkOption {
        type = lib.types.str;
        default = "/";
        description = "Location under which the data logger is reachable";
      };
      fqdn = lib.mkOption {
        type = lib.types.str;
        default = "service-dashboard.kopatz.dev";
        description = "FQDN under which the data logger is reachable";
      };
    };
    kubernetes.enable = lib.mkEnableOption "Enables kubernetes";
    netbird = {
      enable = lib.mkEnableOption "Enables netbird";
      domain = lib.mkOption {
        type = lib.types.str;
        default = "netbird.kopatz.dev";
        description = "Domain for the NetBird management API (e.g. for dashboard and CLI access).";
      };
      baseDir = lib.mkOption {
        type = lib.types.str;
        default = "/1tbssd/netbird";
        description = "Base directory for NetBird state and config (e.g. /var/lib/netbird).";
      };
    };
    netbird-client.enable = lib.mkEnableOption "Enables netbird-client";
    netbird-native = {
      enable = lib.mkEnableOption "Enables netbird-native";
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/netbird";
        description = "Directory to store netbird data";
      };
    };
    nginx = {
      enable = lib.mkEnableOption "Enables nginx";
      https = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Should it use https?";
      };
      dav = lib.mkEnableOption "Enables WebDAV support on /hdd/nginx";
    };
    node-exporter.enable = lib.mkEnableOption "Enables node-exporter";
    opensnitch.enable = lib.mkEnableOption "Enables opensnitch";
    qbittorrent = {
      enable = lib.mkEnableOption "Enables qbittorrent";
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/seed/qb";
        description = "Directory to store uploaded files";
      };
    };
    samba.enable = lib.mkEnableOption "Enables samba";
    smartd.enable = lib.mkEnableOption "Enables smartd monitoring";
    smartd-exporter.enable = lib.mkEnableOption "Enables smartd monitoring";
    ssh.enable = lib.mkEnableOption "Enables ssh";
    step-ca.enable = lib.mkEnableOption "Enables step-ca";
    syncthing = {
      enable = lib.mkEnableOption "Enables syncthing";
      basePath = lib.mkOption {
        type = with lib.types; str;
        default = "/home/${config.mainUser.name}/synced";
        description = "Base path for syncthing data";
      };
    };
    tdata.enable = lib.mkEnableOption "Enables tdata";
    transmission = {
      enable = lib.mkEnableOption "Enables transmission";
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/seed";
        description = "Directory to store uploaded files";
      };
    };
    wireguard = {
      enable = lib.mkEnableOption "Enables wireguard";
      ip = lib.mkOption {
        default = "192.168.2.1";
        type = lib.types.str;
        description = "ipv4 address";
      };
      secretFile = lib.mkOption {
        type = lib.types.path;
        default = ../../../secrets/wireguard-private.age;
        description = "agenix secret file for wireguard";
      };
      externalInterface = lib.mkOption {
        type = lib.types.str;
        default = "eth0";
        description = "external interface";
      };
    };
  };
}
