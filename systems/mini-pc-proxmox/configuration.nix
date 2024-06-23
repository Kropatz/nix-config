# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, modulesPath, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/services/ssh.nix
    ../../modules/services/step-ca.nix
    ../../modules/services/syncthing.nix
    ../../modules/fail2ban.nix
    ../../modules/logging.nix
    ../../modules/motd.nix
    "${toString modulesPath}/virtualisation/proxmox-image.nix"
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  proxmox.qemuConf = {
    memory = 16384;
    cores = 8;
    net0 = "virtio=00:00:00:00:00:00,bridge=vmbr0,firewall=1";
  };
    boot = {
      kernelParams = [ "console=tty0" "console=ttyS0" ];
      loader.timeout = lib.mkForce 1;
    };

  networking.firewall.allowedTCPPorts = [ 25565 ];

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
      firmware.enable = true;
      ssd.enable = true;
    };
    misc = {
      docker.enable = true;
      backup = let
        kavita = "/data/kavita";
        gitolite = "/var/lib/gitolite";
        syncthing = [ "/synced/default/" "/synced/work_drive/" ];
        syncthingFull = syncthing ++ [ "/synced/fh/" "/synced/books/" ];
        backupPathsSmall = [ "/home" gitolite ] ++ syncthing;
        backupPathsMedium = [ "/home" gitolite ] ++ syncthing;
        backupPathsFull = [ "/home" kavita gitolite ] ++ syncthingFull;
      in {
        enable = true;
        small = backupPathsSmall; # goes to backblaze
        medium = backupPathsMedium; # goes to gdrive
        large = backupPathsFull; # goes to local storage medium
      };
    };
    services = {
      acme.enable = true;
      gitolite.enable = true;
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
    };
    nftables.enable = true;
    cli-tools.enable = true;
    nix = {
      index.enable = true;
      ld.enable = true;
      settings.enable = true;
    };
  };

  networking.hostName = "mini-pc-proxmox"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.11"; # Did you read the comment?
}
