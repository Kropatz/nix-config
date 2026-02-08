{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/misc/kernel.nix
    ../../modules/misc/faster-boot-time.nix
    ../../modules/misc/zram.nix
    ../../modules/networkmanager.nix
  ];

  custom = {
    tmpfs.enable = true;
    nftables.enable = true;
    cli-tools.enable = true;
    nix = {
      useLatest = true;
      #index.enable = true;
      #ld.enable = true;
      settings.enable = true;
    };
    static-ip = {
      enable = false;
      interface = "enp42s0";
      ip = "192.168.0.13";
      dns = "192.168.0.10";
    };
    hardware = {
      nvidia = {
        enable = true;
      };
      ssd.enable = true;
    };
    graphical = {
      audio.enable = true;
      games = {
        enable = true;
      };
      #sddm.enable = true;
      hyprland.enable = true;
      shared.enable = true;
      stylix = {
        enable = true;
        base16Scheme = import ../../modules/themes/ina-matugen.nix;
        image = ../../wallpaper/ina.jpg;
      };
      wayvnc.enable = true;
    };
  };

  programs.firefox.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  #services.logind.settings.Login = {
  #  HandlePowerKey = "suspend";
  #};
  nix.gc.automatic = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    #inputs.quickshell.packages.x86_64-linux.default
    #kdePackages.qtdeclarative
    #libimobiledevice
    #ifuse # optional, to mount using 'ifuse'
    (wl-clicker.overrideAttrs (old: {
      # wayland autoclicker
      src = pkgs.fetchFromGitHub {
        owner = "phonetic112";
        repo = "wl-clicker";
        rev = "f0241c374241d6cf74ba3abffb74a3fdcefa6f88";
        hash = "sha256-QwFT9e2FuczC+ew/lDrDnYYccrrfVJi3Rlrurhwk8ZU=";
      };
    }))
  ];

  mainUser.layout = "de";
  mainUser.variant = "us";

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    systemd-boot.enable = true;
  };

  networking.hostName = "test-pc"; # Define your hostname.

  # Configure console keymap
  console.keyMap = "de";

  # Enable automatic login for the user.
  #services.xserver.displayManager.autoLogin.enable = true;
  #services.xserver.displayManager.autoLogin.user = "kopatz";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
