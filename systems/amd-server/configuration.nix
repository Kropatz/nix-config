# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/misc/kernel.nix
    ../../modules/services/ssh.nix
  ];

  custom = {
    #tmpfs.enable = true;
    nftables.enable = true;
    cli-tools.enable = true;
    virt-manager.enable = true;
    nix = {
      index.enable = true;
      ld.enable = true;
      settings.enable = true;
    };
    hardware = {
      amd-gpu.enable = true;
      firmware.enable = true;
      ssd.enable = true;
      wooting.enable = true;
    };
    services = {
      smartd.enable = true;
    };
    graphical = {
      audio.enable = true;
      sddm.enable = true;
      nightlight.enable = true;
      i3.enable = true;
      xfce.enable = true;
      shared.enable = true;
      games.enable = true;
      basics.enable = true;
    };
  };
  mainUser.layout = "de";
  mainUser.variant = "us";

  networking = {
    useDHCP = false;
    defaultGateway.address = "192.168.0.1";
    nameservers = [ "192.168.0.10" "1.1.1.1" ];

    bridges.br0 = { interfaces = [ "enp6s0" ]; };
    interfaces.br0 = {
      ipv4.addresses = [{
        address = "192.168.0.20";
        prefixLength = 24;
      }];
    };
  };

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "xfce4-session";
  services.xrdp.openFirewall = false;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #zenpower for ryzen
  boot.extraModulePackages = with config.boot.kernelPackages; [ zenpower ];
  boot.kernelModules = [ "zenpower" ];
  boot.blacklistedKernelModules = [ "k10temp" ];

  networking.hostName = "amd-server"; # Define your hostname.
  nixpkgs.config.permittedInsecurePackages =
    [ "electron-28.3.3" "electron-27.3.11" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
  ];

  system.stateVersion = "24.05"; # Did you read the comment?

}
