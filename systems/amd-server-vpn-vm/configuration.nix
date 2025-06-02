{ config, pkgs, modulesPath, lib, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    #./hardware-configuration.nix
    ../../modules/services/ssh.nix
    ../../modules/misc/logging.nix
    ../../modules/misc/motd.nix
    ../../modules/misc/kernel.nix
    ../../modules/work/vpn.nix
    #./disk-config.nix
    ./hardware.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    kernelParams = [ "console=tty0" "console=ttyS0" ];
    loader.timeout = lib.mkForce 1;

    loader.grub.enable = true;
    loader.grub.device = "/dev/vda";
    #loader.grub = {
    #  efiSupport = true;
    #  efiInstallAsRemovable = true;
    #  device = "nodev";
    #};
  };

  programs.firefox.enable = true;
  services.spice-vdagentd.enable = true;

  networking.usePredictableInterfaceNames = false;

  mainUser.layout = "de";
  mainUser.variant = "us";
  custom = {
    user = {
      name = "anon";
      layout = "de";
      variant = "us";
    };
    hardware = {
      firmware.enable = true;
      ssd.enable = true;
    };
    services = {
      wireguard = {
        enable = true;
        ip = "192.168.2.1";
        secretFile = ../../secrets/wireguard-evo-vpn.age;
        externalInterface = "tun0";
      };
    };
    nftables.enable = true;
    cli-tools.enable = true;
    nix = {
      index.enable = true;
      settings.enable = true;
    };
    graphical = {
      lxqt.enable = true;
    };
  };

  #fileSystems."/" = {
  #  device = "/dev/disk/by-label/nixos";
  #  fsType = "ext4";
  #  options = [ "defaults" "noatime" ];
  #};
  #fileSystems."/boot" =
  #{ device = "/dev/disk/by-label/ESP";
  #    fsType = "vfat";
  #};

  networking.hostName = "amd-server-vpn-vm"; # Define your hostname.

  # Configure console keymap
  console.keyMap = "us";

  system.stateVersion = "25.05"; # Did you read the comment?
}
