# 0000:2b:00.0 VGA compatible controller [0300]: NVIDIA Corporation GM204 [GeForce GTX 970] [10de:13c2] (rev a1)
# 0000:2b:00.1 Audio device [0403]: NVIDIA Corporation GM204 High Definition Audio Controller [10de:0fbb] (rev a1)
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/misc/kernel.nix
    ../../modules/services/ssh.nix
    ../../modules/services/node-exporter.nix
  ];

  custom = {
    #tmpfs.enable = true;
    nftables.enable = true;
    cli-tools.enable = true;
    virt-manager.enable = true;
    static-ip.ip = "192.168.0.20";
    nix = {
      index.enable = true;
      ld.enable = true;
      settings.enable = true;
    };
    hardware = {
      #amd-gpu.enable = true;
      nvidia.enable = false;
      firmware.enable = true;
      ssd.enable = true;
      vfio = {
        enable = true;
        stub_pci = [
          "10de:13c2"
          "10de:0fbb"
        ]; # nvidia
      };
      wooting.enable = true;
    };
    services = {
      acme.enable = true;
      smartd.enable = true;
      #adguard = {
      #  enable = true;
      #  acme-url = "https://192.168.0.10:8443/acme/kop-acme/directory";
      #};
    };
    graphical = {
      audio.enable = true;
      #sddm.enable = true;
      #nightlight.enable = true;
      #i3.enable = true;
      firefox-custom.enable = true;
      xfce.enable = true;
      #plasma.enable = true;
      #lxqt.enable = true;
      shared.enable = true;
      #games.enable = true;
      #basics.enable = true;
      stylix.enable = true;
    };
  };
  mainUser.layout = "de";
  mainUser.variant = "us";
  services.xserver.displayManager.lightdm.enable = false; # no login manager!

  nix.gc.automatic = lib.mkForce false;
  networking = {
    useDHCP = false;
    defaultGateway.address = "192.168.0.1";
    nameservers = [
      "192.168.0.10"
      "1.1.1.1"
    ];

    bridges.br0 = {
      interfaces = [ "enp42s0" ];
    };
    interfaces.br0 = {
      ipv4.addresses = [
        {
          address = "192.168.0.20";
          prefixLength = 24;
        }
      ];
    };

    firewall.allowedTCPPorts = [
      25565
      25566
    ]; # localsend

  };

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

  services.xrdp = {
    defaultWindowManager = "xfce4-session";
    enable = true;
    openFirewall = false;
    #extraConfDirCommands = ''
    #  substituteInPlace $out/sesman.ini \
    #    --replace LogLevel=INFO LogLevel=DEBUG \
    #    --replace LogFile=/dev/null LogFile=/var/log/xrdp.log
    #'';
  };
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("users")
          && (
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
            action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions"
          )
        )
      {
        return polkit.Result.YES;
      }
    });
  '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #zenpower for ryzen
  boot.extraModulePackages = with config.boot.kernelPackages; [ zenpower ];
  boot.kernelModules = [ "zenpower" ];
  boot.blacklistedKernelModules = [ "k10temp" ];

  networking.hostName = "amd-server"; # Define your hostname.
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

  system.stateVersion = "24.05"; # Did you read the comment?

}
