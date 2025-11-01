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
    ../../modules/misc/kernel.nix
    ../../modules/services/ssh.nix
    ./disk-config.nix
  ];


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
    nix = {
      settings.enable = true;
    };
    hardware = {
      firmware.enable = true;
      ssd.enable = true;
      fingerprint.enable = true;
    };
    graphical = {
      audio.enable = true;
      shared.enable = true;
      plasma.enable = true;
      sddm.enable = true;
    };
  };

  #todo: extract this
  services.xserver = {
    xkb.layout = config.mainUser.layout;
    xkb.variant = config.mainUser.variant;
    enable = true;
  };

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

  mainUser.layout = "de";
  mainUser.variant = "";
  console.useXkbConfig = true;
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dell"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  #networking.extraHosts =
  #''
  #  82.218.12.28 kopatz.ddns.net
  #'';

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

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

  system.stateVersion = "25.05"; # Did you read the comment?
}
