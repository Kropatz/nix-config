# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/flatpak.nix
    ../../modules/gpg.nix
    #../../modules/xanmod-kernel.nix
    ../../modules/kernel-testing.nix
    ../../modules/services/syncthing.nix
    ../../modules/support/ntfs.nix
    ../../modules/fh/writing.nix
    ../../modules/work/vpn.nix
    ../../modules/misc/faster-boot-time.nix
    #../../modules/hardware/ryzenmonitor.nix
    ../../modules/networkmanager.nix
  ];

  custom = {
    tmpfs.enable = true;
    wireshark.enable = true;
    virt-manager.enable = true;
    nftables.enable = true;
    cli-tools.enable = true;
    nix = {
      index.enable = true;
      ld.enable = true;
      settings.enable = true;
    };
    static-ip = {
      enable = true;
      interface = "enp42s0";
      ip = "192.168.0.11";
      #dns = "127.0.0.1";
      dns = "192.168.0.10";
      #gateway = "192.168.0.10";
    };
    misc = { docker.enable = true; };
    services = { syncthing = { enable = true; }; };
    hardware = {
      android.enable = true;
      amd-gpu.enable = true;
      nvidia = {
        enable = false;
        clock = {
          enable = true;
          min = 210;
          max = 1755;
          offset = 230;
        };
      };
      firmware.enable = true;
      ssd.enable = true;
      wooting.enable = true;
      tpm.enable = true;
      #tablet.enable = true;
    };
    graphical = {
      audio.enable = true;
      code = {
        enable = true;
        android.enable = true;
      };
      #emulators.enable = true;
      games = {
        enable = true;
        enablePreinstalled = true;
        enableVr = true;
      };
      ime.enable = true;
      noise-supression.enable = true;
      obs.enable = true;
      #openrgb.enable = true;
      sddm.enable = true;
      nightlight.enable = true;
      #plasma.enable = true;
      i3.enable = true;
      #sway.enable = true;
      hyprland.enable = true;
      #gnome.enable = true;
      #cosmic.enable = true;
      shared.enable = true;
      basics.enable = true;
      stylix = {
        enable = true;
        base16Scheme = import ../../modules/themes/tsukasa.nix;
        image = ../../tsukasa.jpg;
      };
    };
  };
  services.ollama = {
    enable = false;
    acceleration = "cuda";
  };
  virtualisation.waydroid.enable = false;

  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "de_AT.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];

  # apple shit
  #services.usbmuxd.enable = true;
  environment.systemPackages = with pkgs; [
    #libimobiledevice
    #ifuse # optional, to mount using 'ifuse'
    openai-whisper
  ];

  networking.firewall.allowedTCPPorts = [ 6567 ]; # mindustry
  networking.firewall.allowedUDPPorts = [ 6567 ]; # mindustry
  mainUser.layout = "de";
  mainUser.variant = "us";
  age.identityPaths = [ /home/kopatz/.ssh/id_rsa ];
  services.xserver.displayManager.session = [
    #{
    #  manage = "desktop";
    #  name = "hyprland";
    #  start = ''
    #    ${lib.getExe pkgs.hyprland} &
    #    waitPID=$!
    #  '';
    #}
    #{
    #  manage = "desktop";
    #  name = "plasma5";
    #  start = ''
    #    env ${pkgs.plasma-workspace}/bin/startplasma-x11
    #  '';
    #}
  ];

  # not worth it
  # https://github.com/NixOS/nixpkgs/blob/master/lib/systems/architectures.nix
  #nix.settings.system-features = ["znver3" "gccarch-znver3" ];
  #nixpkgs.hostPlatform = {
  #  gcc.arch = "znver3";
  #  gcc.tune = "znver3";
  #  system = "x86_64-linux";
  #};

  # fix index
  services.xserver.extraConfig = ''
    Section "Monitor"
      Identifier "DisplayPort-1"
      Option "PreferredMode" "2880x1600"
    EndSection
  '';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "kop-pc"; # Define your hostname.

  # Enable networking
  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  #services.nscd.enableNsncd = false;
  #disable firewall when doing ipv6 vm stuff
  #networking.firewall.enable = lib.mkForce false;

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure console keymap
  console.keyMap = "en";

  # Enable CUPS to print documents.
  # disable until CVE-2024-47176, CVE-2024-47076, CVE-2024-47175, and CVE-2024-47177 is fixed
  services.printing.enable = false;
  services.printing.drivers = [ pkgs.brlaser ];
  services.avahi = {
    enable = false;
    nssmdns4 = true;
    openFirewall = true;
  };

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
  system.stateVersion = "23.05"; # Did you read the comment?

}
