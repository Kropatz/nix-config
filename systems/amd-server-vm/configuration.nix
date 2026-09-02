{
  config,
  pkgs,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    #./hardware-configuration.nix
    # ../../modules/services/duckdns.nix
    ./disk-config.nix
    ./mail.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # powerManagement.powerUpCommands = ''
  #   ${pkgs.hdparm}/bin/hdparm -B 127 -S 120 /dev/sdd
  # '';

  boot = {
    kernelParams = [
      "console=tty0"
      "console=ttyS0"
    ];
    loader.timeout = lib.mkForce 1;

    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
    };
  };

  mainUser.layout = "de";
  mainUser.variant = "us";
  custom = {
    tmpfs.enable = true;
    static-ip = {
      enable = true;
      ip = "${config.custom.vars.serverIp}";
      interface = "eth0";
      dns = "127.0.0.1";
    };
    hardware = {
      ssd.enable = true;
    };
    misc = {
      docker.enable = true;
      newkernel.enable = true;
      backup =
        let
          kavita = "/data/shares/exposedvm/kavita";
          gitea = [
            "/1tbssd/shares/exposedvm/gitea"
            "/1tbssd/shares/exposedvm/backups/gitea"
          ];
          # opendkim moved to the exposed VM; mail storage stays here.
          mail = [
            "/data/vmail"
          ];
          syncthing = [
            "/data/synced/default/"
            "/data/synced/work_drive/"
          ];
          netbird = [
            "/1tbssd/shares/exposedvm/backups/netbird/etc-netbird/config.yaml"
            "/1tbssd/shares/exposedvm/backups/netbird/var-lib-netbird/store.db"
            "/1tbssd/shares/exposedvm/backups/netbird/var-lib-netbird/idp.db"
            "/1tbssd/shares/exposedvm/backups/netbird/var-lib-netbird/events.db"
          ];
          syncthingFull = [
            "/data/synced/fh/"
            "/data/synced/books/"
          ];
          backupPathsSmall = [
            "/home"
            "/etc/netbird"
          ]
          ++ syncthing
          ++ mail
          ++ netbird;
          backupPathsMedium = gitea
          ++ backupPathsSmall;
          backupPathsFull = [
            kavita
            "/data/shares/exposedvm/ente"
          ]
          ++ gitea
          ++ syncthingFull
          ++ backupPathsMedium;
        in
        {
          enable = true;
          excludePaths = lib.mkOptionDefault [
            "${kavita}/manga"
            "/home/anon/projects"
          ];
          small = backupPathsSmall; # goes to backblaze
          medium = backupPathsMedium; # goes to gdrive
          large = backupPathsFull; # goes to local storage medium
        };
    };
    services = {
      ssh.enable = true;
      acme.enable = true;
      acme-cloudflare.enable = true;
      # gitea = {enable = true; enableNginx = true;};
      fail2ban.enable = true;
      step-ca.enable = true;
      samba.enable = true;
      ddclient-cloudflare.enable = true;
      grafana.enable = true;
      grafana-log-agent.enable = true;
      coturn.enable = true;
      blocklist.enable = true;
      tdata.enable = true;
      # github-runner.enable = true;
      gitea-runner.enable = true;
      kavita-gitea-runner.enable = true;
      caldav.enable = true;
      kop-monitor.enable = true;
      kop-service-dashboard = {
        enable = true;
        dataDir = "/data/service-dashboard";
      };
      kop-pvlog = {
        enable = true;
        basePath = "/";
        dataDir = "/data/pvlog";
      };
      nginx = {
        enable = true;
        dav = true;
      };
      wireguard = {
        enable = true;
        ip = "192.168.2.1";
      };
      adguard = {
        enable = true;
        fqdn = "adguard.kopatz.dev";
      };
      syncthing = {
        enable = true;
        basePath = "/data/synced";
      };
      clamav = {
        enable = true;
        scanDirectories = [
          "/data/vmail"
          "/home"
          "/var/lib"
          "/tmp"
          "/etc"
          "/var/tmp"
          "/1tbssd/shares"
        ];
      };
      netbird.enable = true;
      netbird-client.enable = true;
      dependency-track.enable = false; # TODO: wait until it doesnt use nodejs20 anymore (marked insecure)
    };
    nftables.enable = true;
    cli-tools.enable = true;
    nix = {
      index.enable = true;
      ld.enable = true;
      settings.enable = true;
    };
  };


  users.users.katze = {
    createHome = true;
    isNormalUser = true;
    shell = pkgs.zsh;
    uid = config.custom.vars.uids.katze;
    group = "katze";
  };
  users.groups.katze = {
    gid = config.custom.vars.gids.katze;
  };

  services.openssh.extraConfig = ''
    # Internal network: allow everyone
    Match Address 192.168.2.0/24,192.168.0.0/24
        AllowUsers *

    # Everything else (internet): only git user
    Match Address *,!192.168.2.0/24,!192.168.0.0/24
        PermitRootLogin no
        AllowUsers gitea
  '';

  virtualisation.vmware.guest.enable = true;
  services.xserver.videoDrivers = [ "vmware" ];
  environment.systemPackages = with pkgs; [
    kop-audio
    cifs-utils
  ];

  networking.firewall.allowedTCPPorts = [
    25565
    25566
    # 30033 # teamspeak6 file transfer port
  ];

  networking.firewall.allowedUDPPorts = [
    1234 # kop-audio default port
    #9987 # teamspeak6 voice port
  ];
  networking.hostName = "server-vm"; # Define your hostname.

  #containers.privnetwork = {
  #  autoStart = true;
  #  privateNetwork = true;
  #  privateUsers = "pick";
  #  hostAddress = "192.168.100.1";
  #  localAddress = "192.168.100.2";
  #  config = { config, pkgs, ... }: {
  #      services.postgresql.enable = true;
  #  };
  #};

  #services.murmur = {
  #  enable = true;
  #  openFirewall = true;
  #};

  #fileSystems."/" = {
  #  device = "/dev/disk/by-label/nixos";
  #  fsType = "ext4";
  #  options = [ "defaults" "noatime" ];
  #};
  #fileSystems."/boot" =
  #{ device = "/dev/disk/by-label/ESP";
  #    fsType = "vfat";
  #};
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/d117419d-fce9-4d52-85c7-e3481feaa22a";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "nofail"
    ];
  };
  fileSystems."/1tbssd" = {
    device = "/dev/disk/by-uuid/801d9217-9c38-4ca8-914e-e31361603892";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
      "noatime"
    ];
  };

  fileSystems."/hdd" = {
    device = "/dev/disk/by-uuid/99954059-3801-4abb-a536-0e7802a3e6b4";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
      "noatime"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt 0755 root root -"
    "d /mnt/jakob-nas 0770 jakob-nas jakob-nas -"
  ];

  age.secrets.samba-jakob-nas = {
    file = ../../secrets/samba-jakob-nas.age;
  };
  users.users.jakob-nas = {
    uid = config.custom.vars.uids."jakob-nas";
    group = "jakob-nas";
    isSystemUser = true;
  };
  users.groups.jakob-nas = {
    gid = config.custom.vars.gids."jakob-nas";
  };
  fileSystems."/mnt/jakob-nas" = {
    device = "//192.168.1.125/home"; # not domain name cus DNS doesnt wanna work :)
    fsType = "cifs";
    options =
      let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users,dir_mode=0770,file_mode=0660";
      in
      [
        "${automount_opts},credentials=${config.age.secrets.samba-jakob-nas.path},uid=${toString config.users.users.jakob-nas.uid},gid=${toString config.users.groups.jakob-nas.gid}"
      ];
  };

  # Configure console keymap
  console.keyMap = "us";

  system.stateVersion = "24.11"; # Did you read the comment?
}
