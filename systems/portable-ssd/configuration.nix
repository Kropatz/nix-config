# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../../modules/misc/kernel.nix ];

  specialisation = {
    nvidia = {
      inheritParentConfig = true;
      configuration = {
        custom = {
          hardware = {
            nvidia.enable = true;
          };
        };
      };
    };
    amd-gpu = {
      inheritParentConfig = true;
      configuration = {
        custom = {
          hardware = {
            amd-gpu.enable = true;
          };
        };
      };
    };
  };

  custom = {
    nftables.enable = true;
    cli-tools.enable = true;
    nix = {
      index.enable = true;
      ld.enable = true;
      settings.enable = true;
    };
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
      xfce.enable = true;
      shared.enable = true;
      games.enable = true;
    };
  };
  mainUser.layout = "de";
  mainUser.variant = "";

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "ehci_pci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sd_mod"
    "rtsx_pci_sdmmc"
    "uas"
    "usbcore"
    "ehci_hcd"
    "uhci_hcd"
    "ohci_hcd"
    "scsi_mod"
  ];
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-ssd";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7395-0541";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "portable-ssd"; # Define your hostname.
  nixpkgs.config.permittedInsecurePackages = [
    "electron-28.3.3"
    "electron-27.3.11"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
  ];

  system.stateVersion = "24.11"; # Did you read the comment?

}
