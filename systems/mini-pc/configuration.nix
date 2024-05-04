# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/services/ssh.nix
      ../../modules/services/syncthing.nix
    ];

  mainUser.layout = "de";
  mainUser.variant = "us";
  custom = {
    static-ip = {
      enable = true;
      ip = "192.168.0.10";
      interface = "enp5s0f0";
      dns = "127.0.0.1";
    };
    user = {
      name = "vm";
      layout = "de";
      variant = "us";
    };
    hardware = {
      firmware.enable = true;
      ssd.enable = true;
    };
    services = {
      acme.enable = true;
      nginx.enable = true;
      fileshelter.enable = true;
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

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mini-pc"; # Define your hostname.

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
