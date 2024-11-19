# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  custom = {
    #tmpfs.enable = true;
    nftables.enable = true;
    cli-tools.enable = true;
    nix = {
      index.enable = true;
      ld.enable = true;
      settings.enable = true;
    };
    static-ip = {
      enable = true;
      ip = "192.168.0.20";
      interface = "enp6s0";
      dns = "192.168.0.10";
    };
    #   static-ip = {
    #     enable = true;
    #     interface = "enp42s0";
    #     ip = "192.168.0.11";
    #     #dns = "127.0.0.1";
    #     dns = "192.168.10";
    #     #gateway = "192.168.0.10";
    #   };
    # It uses 1.1.1.1 for some reason? set in /etc/dnsmasq-resolv.conf. no idea why
    #services.dnsmasq = {
    #  enable = true;
    #  server = [ "192.168.0.10" ];
    #};
    services = { syncthing = { enable = true; }; };
    hardware = {
      firmware.enable = true;
      ssd.enable = true;
      wooting.enable = true;
    };
    graphical = {
      audio.enable = true;
      sddm.enable = true;
      nightlight.enable = true;
      i3.enable = true;
      shared.enable = true;
      games = { enable = true; };
    };
  };
  mainUser.layout = "de";
  mainUser.variant = "us";

  virtualisation.vmware.host.enable = true;

  systemd.services.start-vm = {
    description = "Start VM";
    wants = [ "network-online.target" ];
    after = [ "network.target" "network-online.target" "vmware-networks.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "forking"; #?????? doesnt work without it, thanks vmware
      ExecStart = let
        script = pkgs.writeShellScript "start-vm" ''
          ${pkgs.vmware-workstation}/bin/vmrun start /root/vmware/server/server.vmx nogui
        '';
      in "${script}";
      User = "root";
      Restart = "on-failure";
      RestartSec = "5s";
      ProtectHome = false;
      ProtectSystem = false;
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  #zenpower for ryzen
  boot.extraModulePackages = with config.boot.kernelPackages; [ zenpower ];
  boot.kernelModules = [ "zenpower" ];
  boot.blacklistedKernelModules = [ "k10temp" ];

  services.xserver.desktopManager = {
    xfce.enable = true;
    xterm.enable = false;
  };

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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?

}
