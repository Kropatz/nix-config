{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking = {
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };

    interfaces.enp1s0 = {
      ipv6.addresses = [ {
        address = "2a01:4f8:c013:232b::2";
        prefixLength = 64;
      } ];
    };
  };
  custom = {
    services = {
      acme.enable = true;
      adam-site.enable = true;
      plausible.enable = true;
    };
    nftables.enable = true;
    nix = { settings.enable = true; };
  };

  age.secrets.stash-auth = {
    file = ../../secrets/adminarea.age;
    owner = "nginx";
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    virtualHosts = {
      "imbissaggsbachdorf.at" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/".proxyPass = "http://127.0.0.1:4000";
          "/admin" = {
            basicAuthFile = config.age.secrets.stash-auth.path;
            proxyPass = "http://127.0.0.1:4000";
          };
          "/api/admin" = {
            basicAuthFile = config.age.secrets.stash-auth.path;
            proxyPass = "http://127.0.0.1:4000";
          };
        };
      };
      "plausible.imbissaggsbachdorf.at" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://127.0.0.1:8000";
      };
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMypKJQvn68s8iNk9J9zghFlW4nrd03FwqfvGQ9sAmWojXe6pKrkat++8grIfB60aiIwNjHeXigVdZrpIb0QiR7+maPLPtxySTmgD7GeyAbwJrAymgKAzJcQvq5tKHtjH60KhLe4QzGXXpjoGIhl/8FhepRT6306JE8OfMwBUwOa3wcEdeJ7eK4JZdELCne3Gj16eWHy8iNIQswNtvJ70M7RACyDJARuazde3zFqkRYCP9Rqinegg/DVd+ykC2qHqM/yCersCOGn+I3hPCS1tz/AhDTQ7T9A7j5CLjv6ZbRS+B7a7u7z5qOAla468sELaiAEo2+fovlh8kib5zzWM2pK3rSEfUzFVGAAfHtrdR8pYynl3DBNC5XGzDT8xqa4B/qJIRoPmr8CMroLBOGGZQm9TJbmhfl8vT96RUwOA6qUmLQl6b0qJRRMkvlgCvKZyZ3d6pPfizQigTn1evBveqO9dgGcCAyAi0Ob6JZisTWUn5nAqe7CR1h2EKC0lqdCc="
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKJTpEPKK38MQHcLHkJ6TCqrhSQ9B2ruVx6ONRVQYJC6"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPb326bQdoNNQ/z38C07TbyhNoj59eJTHRHaMqHSHBXy"
  ];
  environment.systemPackages = map lib.lowPrio [ pkgs.curl pkgs.gitMinimal ];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  age.secrets.webhook = {
    file = ../../secrets/webhook.age;
  };
  # service that runs all the time, pkgs.kop-monitor
  systemd.services.kop-monitor = {
    description = "Kop Monitor";
    wants = [ "network-online.target" ];
    after = [ "network.target" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ "${pkgs.iputils}" ];
    serviceConfig = with lib; {
      Type = "simple";
      ExecStart = "${(pkgs.kop-monitor.overrideAttrs {
          src = fetchGit {
            url = "git@github.com:kropatz/monitor.git";
            ref = "monitor-homeserver";
            rev = "14e84874302146690491a8ced7e3c89dce183a74";
          };
      })}/bin/monitor";
      DynamicUser = true;
      Restart = "on-failure";
      RestartSec = "5s";
      EnvironmentFile = config.age.secrets.webhook.path;
      PrivateMounts = mkDefault true;
      PrivateTmp = mkDefault true;
      PrivateUsers = mkDefault true;
      ProtectClock = mkDefault true;
      ProtectControlGroups = mkDefault true;
      ProtectHome = mkDefault true;
      ProtectHostname = mkDefault true;
      ProtectKernelLogs = mkDefault true;
      ProtectKernelModules = mkDefault true;
      ProtectKernelTunables = mkDefault true;
      ProtectSystem = mkDefault "strict";
      # Needs network access
      PrivateNetwork = mkDefault false;
    };

  };
  system.stateVersion = "23.11";
}
