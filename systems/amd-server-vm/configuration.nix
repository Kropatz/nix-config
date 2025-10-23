{ config, pkgs, modulesPath, lib, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    #./hardware-configuration.nix
    ../../modules/services/ssh.nix
    ../../modules/services/step-ca.nix
    ../../modules/services/fail2ban.nix
    ../../modules/misc/logging.nix
    ../../modules/misc/motd.nix
    ../../modules/misc/kernel.nix
    ../../modules/services/duckdns.nix
    ../../modules/services/samba.nix
    ../../modules/services/ddclient-cloudflare.nix
    ./disk-config.nix
    ./mail.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    kernelParams = [ "console=tty0" "console=ttyS0" ];
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
    static-ip = {
      enable = true;
      ip = "192.168.0.10";
      interface = "eth0";
      dns = "127.0.0.1";
    };
    user = {
      name = "anon";
      layout = "de";
      variant = "us";
    };
    hardware = {
      ssd.enable = true;
    };
    misc = {
      docker.enable = true;
      backup =
        let
          kavita = "/data/kavita";
          gitolite = "/var/lib/gitolite";
          mail = [ "/data/vmail" "/var/lib/opendkim" ];
          syncthing = [ "/data/synced/default/" "/data/synced/work_drive/" ];
          syncthingFull = syncthing
            ++ [ "/data/synced/fh/" "/data/synced/books/" ];
          backupPathsSmall = [ "/home" gitolite ] ++ syncthing ++ mail;
          backupPathsMedium = [ "/home" gitolite ] ++ syncthing ++ mail;
          backupPathsFull = [ "/home" kavita gitolite ] ++ syncthingFull ++ mail;
        in
        {
          enable = true;
          excludePaths = lib.mkOptionDefault [ "${kavita}/manga" "/home/anon/projects" ];
          small = backupPathsSmall; # goes to backblaze
          medium = backupPathsMedium; # goes to gdrive
          large = backupPathsFull; # goes to local storage medium
        };
    };
    services = {
      acme.enable = true;
      gitolite.enable = true;
      github-runner.enable = true;
      caldav.enable = true;
      kop-monitor.enable = true;
      kop-fileshare = {
        basePath = "/stash";
        dataDir = "/1tbssd/kop-fileshare";
        enable = true;
      };
      nginx.enable = true;
      ente.enable = true;
      kavita = {
        enable = true;
        dir = "/data/kavita";
      };
      wireguard = {
        enable = true;
        ip = "192.168.2.1";
      };
      adguard.enable = true;
      syncthing = {
        enable = true;
        basePath = "/data/synced";
      };
    };
    nftables.enable = true;
    cli-tools.enable = true;
    nix = {
      index.enable = true;
      ld.enable = true;
      settings.enable = true;
    };
  };

  virtualisation.vmware.guest.enable = true;
  services.xserver.videoDrivers = [ "vmware" ];

  # 8888 = scheibenmeister skip button
  networking.firewall.allowedTCPPorts = [ 25565 25566 8888 ];
  networking.nftables.tables.ip_drop = {
    family = "inet";
    content = ''
      set blocked-ip4 {
        typeof ip saddr
        flags interval
        auto-merge
        elements = { 45.144.212.240 }
      }
      chain input {
        # -100 priority to run before the default filter input chain (0)
        type filter hook input priority -100; policy accept;

        ip saddr @blocked-ip4 log prefix "nftables drop: " level info counter drop
      }
    '';
  };
  networking.hostName = "server-vm"; # Define your hostname.

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
    options = [ "compress=zstd" "noatime" "nofail" ];
  };
  fileSystems."/1tbssd" = {
    device = "/dev/disk/by-uuid/801d9217-9c38-4ca8-914e-e31361603892";
    fsType = "ext4";
    options = [ "defaults" "nofail" "noatime" ];
  };

  fileSystems."/hdd" = {
    device = "/dev/disk/by-uuid/99954059-3801-4abb-a536-0e7802a3e6b4";
    fsType = "ext4";
    options = [ "defaults" "nofail" "noatime" ];
  };


  # Configure console keymap
  console.keyMap = "us";

  system.stateVersion = "24.11"; # Did you read the comment?
}
