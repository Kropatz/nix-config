{
  config,
  pkgs,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    #./hardware-configuration.nix
    ../../modules/services/ssh.nix
    ../../modules/misc/logging.nix
    ../../modules/misc/motd.nix
    ./disk-config.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    kernelParams = [
      "console=tty0"
      "console=ttyS0"
    ];
    loader.timeout = lib.mkForce 1;

    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
    };
  };

  mainUser.layout = "de";
  mainUser.variant = "us";
  custom = {
    tmpfs.enable = true;
    static-ip = {
      enable = true;
      ip = "${config.custom.vars.exposedServerIp}";
      interface = "eth0";
      dns = "127.0.0.1";
    };
    hardware = {
      ssd.enable = true;
    };
    misc = {
      newkernel.enable = true;
    };
    services = {
      kop-fileshare = {
        basePath = "/stash";
        dataDir = "/mnt/kop-fileshare";
        port = 7777;
        listenAddr = "0.0.0.0";
        enable = true;
      };
    };
    nftables.enable = true;
    cli-tools.enable = true;
    nix = {
      index.enable = true;
      settings.enable = true;
    };
  };
  
  networking.firewall.extraInputRules = "ip saddr ${config.custom.vars.serverIp} tcp dport ${toString config.custom.services.kop-fileshare.port} counter accept comment allow_from_main_server";

  services.openssh.extraConfig = ''
    # Internal network: allow everyone
    Match Address 192.168.2.0/24,192.168.0.0/24
        AllowUsers *

    # Everything else (internet): only git user
    Match Address *,!192.168.2.0/24,!192.168.0.0/24
        PermitRootLogin no
        AllowUsers gitea
  '';

  virtualisation.vmware.guest.enable = true;
  services.xserver.videoDrivers = [ "vmware" ];

  # 8888 = scheibenmeister skip button
  networking.firewall.allowedTCPPorts = [
    # 25565
    # 25566
    # 8888
    # 30033 # teamspeak6 file transfer port
  ];

  networking.firewall.allowedUDPPorts = [
    # 1234 #kop-audio default port
    # 9987 # teamspeak6 voice port
  ];
  networking.hostName = "amd-server-exposed-vm"; # Define your hostname.

  # fileSystems = {
  #   "/" = {
  #     device = "/dev/disk/by-label/nixos";
  #     autoResize = true;
  #     fsType = "ext4";
  #   };
  #   "/boot" = lib.mkIf (cfg.efiSupport) {
  #     device = "/dev/disk/by-label/ESP";
  #     fsType = "vfat";
  #   };
  # };

  age.secrets.samba-exposedvm = {
    file = ../../secrets/samba-exposedvm.age;
  };
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/medium" = {
    device = "//${config.custom.vars.serverIp}/medium";
    fsType = "cifs";
    options =
      let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";

      in
      [ "${automount_opts},credentials=${config.age.secrets.samba-exposedvm.path},uid=1000,gid=100" ];
    # or if you have specified `uid` and `gid` explicitly through NixOS configuration,
    # you can refer to them rather than hard-coding the values:
    # in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=${toString config.users.users.<username>.uid},gid=${toString config.users.groups.<group>.gid}"];
  };
  fileSystems."/mnt/kop-fileshare" = {
    device = "//${config.custom.vars.serverIp}/medium/kop-fileshare";
    fsType = "cifs";
    options =
      let
        automount_opts = "x-systemd.automount,noauto,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";

      in
      [ "${automount_opts},credentials=${config.age.secrets.samba-exposedvm.path},uid=${toString config.users.users.kop-fileshare.uid},gid=${toString config.users.groups.kop-fileshare.gid}" ];
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

  # fileSystems."/data" = {
  #   device = "/dev/disk/by-uuid/d117419d-fce9-4d52-85c7-e3481feaa22a";
  #   fsType = "btrfs";
  #   options = [
  #     "compress=zstd"
  #     "noatime"
  #     "nofail"
  #   ];
  # };
  # fileSystems."/1tbssd" = {
  #   device = "/dev/disk/by-uuid/801d9217-9c38-4ca8-914e-e31361603892";
  #   fsType = "ext4";
  #   options = [
  #     "defaults"
  #     "nofail"
  #     "noatime"
  #   ];
  # };
  #
  # fileSystems."/hdd" = {
  #   device = "/dev/disk/by-uuid/99954059-3801-4abb-a536-0e7802a3e6b4";
  #   fsType = "ext4";
  #   options = [
  #     "defaults"
  #     "nofail"
  #     "noatime"
  #   ];
  # };

  # Configure console keymap
  console.keyMap = "us";

  system.stateVersion = "24.11"; # Did you read the comment?
}
