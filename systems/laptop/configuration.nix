{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  cec = "${pkgs.v4l-utils}/bin/cec-ctl";
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/battery.nix
    ../../modules/misc/faster-boot-time.nix
    #../../modules/ecryptfs.nix
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
    ./disk-config.nix
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

  # issue with internal mic not workin
  # ... didn't work
  services.pipewire.wireplumber.extraConfig.no-ucm = {
    "monitor.alsa.properties" = {
      "alsa.use-ucm" = false;
    };
  };

  # after suspend, do `cec-ctl -A | grep cec0 | wc -l`, if >0, do `cec-ctl --standby --to TV`
  # similar on wakeup, if present send `cec-ctl --user-control-pressed ui-cmd=power-on-function --to TV`
  environment.etc."systemd/system-sleep/sleep-turn-tv-off-on.sh".source =
    pkgs.writeShellScript "post-sleep-turn-tv-off.sh" ''
      case $1/$2 in
        pre/*)
          if [ $(${cec} -A | ${pkgs.gnugrep}/bin/grep cec0 | ${pkgs.coreutils}/bin/wc -l) -gt 0 ]; then
            ${cec} -C --skip-info
            ${cec} --tv --skip-info
            ${cec} --standby --skip-info --to TV
            echo "Turning TV off!"
            ${pkgs.coreutils}/bin/sleep 2
          fi
          ;;
        post/*)
          if [ $(${cec} -A | ${pkgs.gnugrep}/bin/grep cec0 | ${pkgs.coreutils}/bin/wc -l) -gt 0 ]; then
            ${cec} --tv --skip-info
            ${cec} --skip-info --user-control-pressed ui-cmd=power-on-function --to TV
            echo "Turning TV on!"
          fi
          ;;
      esac
    '';

  custom = {
    cli-tools.enable = true;
    tmpfs.enable = true;
    wireshark.enable = true;
    virt-manager.enable = true;
    nixvimPlugins = true;
    nix = {
      ld.enable = true;
      index.enable = true;
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
      fingerprint.enable = true;
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
      firefox-custom.enable = true;
      #emulators.enable = true;
      hyprland.enable = true;
      games.enable = true;
      ime.enable = false; # causes reatively high cpu usage on hyprland
      shared.enable = true;
      stylix = {
        enable = true;
        base16Scheme = import ../../modules/themes/ina.nix;
        image = ../../wallpaper/ina.jpg;
      };
      wayvnc.enable = true;
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-27.3.11"
    "electron-28.3.3"
  ];
  hardware.cpu.amd.ryzen-smu.enable = true;
  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
    ryzenadj
    prismlauncher
    #fscrypt-experimental
  ];
  # don't think there is a way to unlock this with fingerprint
  #security.pam.enableFscrypt = true;

  #services.joycond.enable = true;

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
  boot = {
    consoleLogLevel = 3;
    initrd.verbose = false;
    plymouth.enable = true;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };

  age.identityPaths = [
    "/home/kopatz/.ssh/id_ed25519"
    "/etc/ssh/ssh_host_ed25519_key"
  ];
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

  networking.hostName = "framework"; # Define your hostname.
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
