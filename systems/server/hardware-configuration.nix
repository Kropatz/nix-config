# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1af836fb-ffef-4362-84af-bcb24d4db068";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B9EB-F6A4";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/e4bf3959-4d3c-4980-82c1-c5ec2104ec93"; }
    ];

  fileSystems."/mnt/2tb" =
    { device = "/dev/disk/by-uuid/99954059-3801-4abb-a536-0e7802a3e6b4";
      fsType = "ext4";
      options = ["defaults" "nofail"];
    };
  
  fileSystems."/mnt/1tb" =
    { device = "/dev/disk/by-uuid/fb0a94c2-95df-4f62-904e-695d372363e9";
      fsType = "ext4";
      options = ["defaults" "nofail"];
    };
  
  fileSystems."/mnt/250ssd" =
    { device = "/dev/disk/by-uuid/80163cf9-2030-4757-ada2-03db96184961";
      fsType = "ext4";
      options = ["defaults" "nofail"];
     };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp6s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}