# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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
    ../../modules/flatpak.nix
    ../../modules/gpg.nix
    #../../modules/xanmod-kernel.nix
    #../../modules/kernel-testing.nix
    ../../modules/misc/kernel.nix
    ../../modules/services/syncthing.nix
    ../../modules/support/ntfs.nix
    ../../modules/fh/writing.nix
    ../../modules/work/vpn.nix
    ../../modules/misc/faster-boot-time.nix
    ../../modules/misc/zram.nix
    #../../modules/hardware/ryzenmonitor.nix
    ../../modules/networkmanager.nix
    #./tailscale-client.nix
  ];

  custom = {
    tmpfs.enable = true;
    wireshark.enable = true;
    virt-manager.enable = true;
    nftables.enable = true;
    cli-tools.enable = true;
    nixvimPlugins = true;
    nix = {
      useLatest = true;
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
    misc = {
      podman.enable = true;
    };
    services = {
      syncthing = {
        enable = true;
      };
      adguard.ip = "192.168.0.10";
    };
    hardware = {
      android.enable = true;
      amd-gpu = {
        enable = true;
        rocm.enable = true;
        overdrive = true;
      };
      vr.enable = true;
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
      gpu-screen-recorder-ui.enable = true;
      niri.enable = false;
      #openrgb.enable = true;
      sddm.enable = true;
      #plasma.enable = true;
      #i3.enable = true;
      #sway.enable = true;
      hyprland.enable = true;
      #gnome.enable = true;
      #cosmic.enable = true;
      shared.enable = true;
      basics.enable = true;
      stylix = {
        enable = true;
        base16Scheme = import ../../modules/themes/ina.nix;
        image = ../../wallpaper/ina.jpg;
      };
    };
  };

  nix.gc.automatic = lib.mkForce false;
  services.searx = {
    enable = false;
    settings = {
      use_default_settings = true;
      server.port = 8787;
      server.bind_address = "0.0.0.0";
      server.secret_key = "1";
      search = {
        favicon_resolver = "duckduckgo";
      };
    };

  };
  services.ollama = {
    enable = false;
    package = pkgs.ollama-vulkan;
  };
  services.jenkins.enable = false;
  virtualisation.waydroid.enable = false;

  systemd.user.services.scheibnkleister-presence = {
    description = "scheibnkleister-presence";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.scheibnkleister-presence}/bin/scheibnkleister-presence";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # apple shit
  #services.usbmuxd.enable = true;
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
  documentation.man.generateCaches = true;

  #networking.firewall.allowedTCPPorts = [ 6567 ]; # mindustry
  networking.firewall.allowedUDPPorts = [ 1234 ]; #6567 ]; # mindustry
  mainUser.layout = "de";
  mainUser.variant = "us";
  age.identityPaths = [ /home/kopatz/.ssh/id_rsa ];

  # fix index
  services.xserver.extraConfig = ''
    Section "Monitor"
      Identifier "DisplayPort-1"
      Option "PreferredMode" "2880x1600"
    EndSection
  '';

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    systemd-boot.enable = true;
    #grub = {
    #  enable = true;
    #  efiSupport = true;
    #  device = "nodev";
    #  theme = "${pkgs.hollow-grub}/grub/theme";
    #};
  };
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "kop-pc"; # Define your hostname.

  # Enable networking
  #boot.initrd.systemd.network.wait-online.enable = false;
  #systemd.network.wait-online.enable = false;

  #services.nscd.enableNsncd = false;
  #disable firewall when doing ipv6 vm stuff
  #networking.firewall.enable = lib.mkForce false;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure console keymap
  console.keyMap = "us";

  # Enable CUPS to print documents.
  # disable until CVE-2024-47176, CVE-2024-47076, CVE-2024-47175, and CVE-2024-47177 is fixed
  # http://localhost:631
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

  networking.hosts =
    let
      addr_to_domain_list =
        config.custom.services.adguard.rewrites
        |> map (x: {
          "${x.answer}" = [ x.domain ];
        });
      flattened = builtins.foldl' (
        acc: elem:
        let
          ip = builtins.head (builtins.attrNames elem);
          names = elem.${ip};
        in
        acc
        // {
          ${ip} = (acc.${ip} or [ ]) ++ names;
        }
      ) { } addr_to_domain_list;
    in
    flattened;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
