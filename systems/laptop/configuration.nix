{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/battery.nix
    ../../modules/ecryptfs.nix
    #../../modules/fh/scanning.nix
    ../../modules/support/ntfs.nix
    ../../modules/thunderbolt.nix
    ../../modules/misc/kernel.nix
    ../../modules/services/wireguard-client.nix
    ../../modules/services/ssh.nix
    ../../modules/work/vpn.nix
    #../../modules/vmware-host.nix
    #../../modules/fh/forensik.nix
    #../../modules/no-sleep-lid-closed.nix
    #../../modules/static-ip.nix
    #../../modules/wake-on-lan.nix
    #./modules/wireguard.nix
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

  custom = {
    cli-tools.enable = true;
    tmpfs.enable = true;
    wireshark.enable = true;
    virt-manager.enable = true;
    nixvimPlugins = true;
    nix = {
      ld.enable = true;
      settings.enable = true;
    };
    misc = {
      docker.enable = true;
      firejail.enable = true;
    };
    hardware = {
      firmware.enable = true;
      ssd.enable = true;
      #tablet.enable = true;
      #fingerprint.enable = true;
    };
    services = {
      syncthing.enable = true;
    };
    graphical = {
      audio.enable = true;
      basics.enable = true;
      code = {
        enable = true;
        #android.enable = true;
      };
      #emulators.enable = true;
      hyprland.enable = true;
      games.enable = true;
      ime.enable = true;
      shared.enable = true;
      stylix = {
        enable = true;
        base16Scheme = import ../../modules/themes/tsukasa.nix;
        image = ../../tsukasa.jpg;
      };
    };
  };

  nixpkgs.config.permittedInsecurePackages = [ "electron-27.3.11" "electron-28.3.3" ];
  services.fprintd.enable = true;
  hardware.cpu.amd.ryzen-smu.enable = true;
  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
    ryzenadj
  ];

  services.joycond.enable = true;

  #todo: extract this
  services.xserver = {
    xkb.layout = config.mainUser.layout;
    xkb.variant = config.mainUser.variant;
    enable = true;
    displayManager.gdm.enable = true;
  };
  #programs.firejail.wrappedBinaries = with pkgs;
  #  let inherit (config.custom.misc.firejail) mk;
  #  in lib.mkMerge [
  #    (mk "Discord" { pkg = discord; })
  #  ];

  services.blueman.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = false; # powers up the default Bluetooth controller on boot

  age.identityPaths =
    [ "/home/kopatz/.ssh/id_ed25519" "/etc/ssh/ssh_host_ed25519_key" ];
  mainUser.layout = "de_us_swapped";
  mainUser.variant = "";
  console.useXkbConfig = true;
  services.xserver.exportConfiguration = lib.mkForce true;
  services.xserver.extraLayouts = {
    de_us_swapped = {
      description = "German (US, Z and Y swapped)";
      languages = [ "de" ];
      symbolsFile = pkgs.writeText "symbols" ''
        default partial alphanumeric_keys
        xkb_symbols "de_us_swapped" {
          include "de(us)"

          name[Group1]= "German (US, Z and Y swapped)";

          key <AB01> { [ y, Y ] };
          key <AD06> { [ z, Z ] };
        };
      '';
    };
  };
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nix-laptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  #networking.extraHosts =
  #''
  #  82.218.12.28 kopatz.ddns.net
  #'';

  # Enable CUPS to print documents.
  # disable until CVE-2024-47176, CVE-2024-47076, CVE-2024-47175, and CVE-2024-47177 is fixed
  services.printing.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  ### docker
  #virtualisation.docker.enable = true;

  #systemd.tmpfiles.rules = [
  #  "d /docker-data 0755 kopatz users"
  #];

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIBjTCCATKgAwIBAgIRAMVH2+JHZ3wm2fLUlKjTYDswCgYIKoZIzj0EAwIwJDEM
      MAoGA1UEChMDS29wMRQwEgYDVQQDEwtLb3AgUm9vdCBDQTAeFw0yMzEyMDgxNDUx
      MTZaFw0zMzEyMDUxNDUxMTZaMCQxDDAKBgNVBAoTA0tvcDEUMBIGA1UEAxMLS29w
      IFJvb3QgQ0EwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAATdZBOkNynShXipzhuX
      f6dUByD3chNupNWsagYC5AlPRJT9fAeHEIK/bxWkFwRtLBDopWvBu9lHahBgpHc7
      y7rTo0UwQzAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBATAdBgNV
      HQ4EFgQU9AVtwipW5HDBLfZRH1KZCnIKCfowCgYIKoZIzj0EAwIDSQAwRgIhAMHj
      AipNdhQKIYPvMt/h1uW4xP3NTkitnmshM09+rIasAiEAlSalGddXDkqJBHhPD+Fr
      gpuVkfVkA8gQCXNs5F9TnxA=
      -----END CERTIFICATE-----
    ''
  ];

  system.stateVersion = "23.05"; # Did you read the comment?
}
