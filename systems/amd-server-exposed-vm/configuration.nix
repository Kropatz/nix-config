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
    ../../modules/services/fail2ban.nix
    ../../modules/misc/logging.nix
    ../../modules/misc/motd.nix
    # ../../modules/microvm/routed-network.nix
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
      interface = "enp1s0";
      renameInterface = false;
      dns = "192.168.0.10";
    };
    hardware = {
      ssd.enable = true;
    };
    misc = {
      newkernel.enable = true;
      zram.enable = true;
    };
    services = {
      kop-sanitizer-bot.enable = true;
      jellyfin.enable = true;
      kop-fileshare = {
        basePath = "/stash";
        dataDir = "/mnt/kop-fileshare";
        port = 7777;
        listenAddr = "0.0.0.0";
        enable = true;
      };
      transmission = {
        enable = true;
        dataDir = "/mnt/seed";
      };
      kavita = {
        enable = true;
        autoDownload = false;
        dir = "/mnt/kavita";
      };
    };
    nftables.enable = true;
    cli-tools.enable = true;
    nix = {
      index.enable = true;
      settings.enable = true;
    };
  };

  networking.firewall.extraInputRules = ''
    ip saddr ${config.custom.vars.serverIp} tcp dport ${toString config.custom.services.kop-fileshare.port} counter accept comment allow_from_main_server
    ip saddr ${config.custom.vars.serverIp} tcp dport ${toString config.services.kavita.settings.Port} counter accept comment allow_from_main_server
    ip saddr ${config.custom.vars.serverIp} tcp dport 8096 counter accept comment allow_jellyfin_from_main_server
  '';

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

  # ssh -J root@192.168.0.22 root@10.0.0.1
  # microvm.vms = {
  #   my-microvm = {
  #     # (Optional) A set of special arguments to be passed to the MicroVM's NixOS modules.
  #     specialArgs = {
  #       index = 1;
  #     };
  #
  #     # The configuration for the MicroVM.
  #     # Multiple definitions will be merged as expected.
  #     config = {
  #       imports = [
  #         ../../modules/services/ssh.nix
  #         ../../users/default.nix
  #         ../../modules/microvm/routed-network-guest.nix
  #       ];
  #       # It is highly recommended to share the host's nix-store
  #       # with the VMs to prevent building huge images.
  #
  #       mainUser.sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2 kopatz";
  #       environment.systemPackages = with pkgs; [ btop  gdu];
  #       microvm = {
  #         hotpluggedMem = 256;
  #         hotplugMem = 1024;
  #         shares = [
  #           {
  #             source = "/nix/store";
  #             mountPoint = "/nix/.ro-store";
  #             tag = "ro-store";
  #             proto = "virtiofs";
  #           }
  #         ];
  #       };
  #
  #       # Any other configuration for your MicroVM
  #       # [...]
  #     };
  #   };
  # };

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
      [
        "${automount_opts},credentials=${config.age.secrets.samba-exposedvm.path},uid=${toString config.users.users.kop-fileshare.uid},gid=${toString config.users.groups.kop-fileshare.gid}"
      ];
  };

  fileSystems."/mnt/kavita" = {
    device = "//${config.custom.vars.serverIp}/small/kavita";
    fsType = "cifs";
    options =
      let
        automount_opts = "x-systemd.automount,noauto,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";
      in
      [
        "${automount_opts},credentials=${config.age.secrets.samba-exposedvm.path},uid=${toString config.users.users.kavita.uid},gid=${toString config.users.groups.kavita.gid}"
      ];
  };
  fileSystems."/mnt/seed" = {
    device = "//${config.custom.vars.serverIp}/large/seed";
    fsType = "cifs";
    options =
      let
        automount_opts = "x-systemd.automount,noauto,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";
      in
      [
        "${automount_opts},credentials=${config.age.secrets.samba-exposedvm.path},uid=${toString config.users.users.transmission.uid},gid=${toString config.users.groups.transmission.gid}"
      ];
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
