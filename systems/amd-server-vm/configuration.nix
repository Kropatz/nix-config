{ config, pkgs, modulesPath, lib, ... }:

let
  tmp_dovecot_passwords = "kopatz:{PLAIN}password:5000:5000::/home/kopatz";
in
{
  imports = [
    # Include the results of the hardware scan.
    #./hardware-configuration.nix
    ../../modules/services/ssh.nix
    ../../modules/services/step-ca.nix
    ../../modules/services/fail2ban.nix
    ../../modules/misc/logging.nix
    ../../modules/misc/motd.nix
    ../../modules/misc/kernel.nix
    ../../modules/services/duckdns.nix
    ./disk-config.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    kernelParams = [ "console=tty0" "console=ttyS0" ];
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
    static-ip = {
      enable = true;
      ip = "192.168.0.10";
      interface = "eth0";
      dns = "127.0.0.1";
    };
    user = {
      name = "anon";
      layout = "de";
      variant = "us";
    };
    hardware = {
      ssd.enable = true;
    };
    misc = {
      docker.enable = true;
      backup =
        let
          kavita = "/data/kavita";
          gitolite = "/var/lib/gitolite";
          syncthing = [ "/data/synced/default/" "/data/synced/work_drive/" ];
          syncthingFull = syncthing
            ++ [ "/data/synced/fh/" "/data/synced/books/" ];
          backupPathsSmall = [ "/home" gitolite ] ++ syncthing;
          backupPathsMedium = [ "/home" gitolite ] ++ syncthing;
          backupPathsFull = [ "/home" kavita gitolite ] ++ syncthingFull;
        in
        {
          enable = true;
          excludePaths = lib.mkOptionDefault [ "${kavita}/manga" "/home/anon/projects" ];
          small = backupPathsSmall; # goes to backblaze
          medium = backupPathsMedium; # goes to gdrive
          large = backupPathsFull; # goes to local storage medium
        };
    };
    services = {
      acme.enable = true;
      gitolite.enable = true;
      github-runner.enable = true;
      caldav.enable = true;
      kop-monitor.enable = true;
      kop-fileshare = {
        basePath = "/stash";
        dataDir = "/1tbssd/kop-fileshare";
        enable = true;
      };
      nginx.enable = true;
      ente.enable = true;
      kavita = {
        enable = true;
        dir = "/data/kavita";
      };
      wireguard = {
        enable = true;
        ip = "192.168.2.1";
      };
      adguard.enable = true;
      syncthing = {
        enable = true;
        basePath = "/data/synced";
      };
    };
    nftables.enable = true;
    cli-tools.enable = true;
    nix = {
      index.enable = true;
      ld.enable = true;
      settings.enable = true;
    };
  };

  virtualisation.vmware.guest.enable = true;
  services.xserver.videoDrivers = [ "vmware" ];

  users = {
    users = {
      vmail = {
        isSystemUser = true;
        description = "Virtual mail user";
        home = "/data/vmail";
        uid = 5000;
        group = "vmail";
      };
    };
    groups = {
      vmail = {
        gid = 5000;
      };
    };
  };
  systemd.tmpfiles.rules = [ "d /data/vmail 0700 vmail vmail -" ];
  services.postfix = {
    enable = true;
    settings.main = {
      myhostname = "mail-kopatz.duckdns.org";
      mydomain = "mail-kopatz.duckdns.org";
      #myorigin = "$mydomain";
      mynetworks = [ "127.0.0.0/8" "192.168.0.0/24" "192.168.2.0/24" ];
      mydestination = [ "localhost.$mydomain" "localhost" ];
      recipient_delimiter = "+";
      virtual_mailbox_domains = [ "mail-kopatz.duckdns.org" ];
      virtual_mailbox_base = "/data/vmail";
      virtual_mailbox_maps = "hash:/etc/postfix/virtual-map";
      virtual_uid_maps = "static:${toString config.users.users.vmail.uid}";
      virtual_gid_maps = "static:${toString config.users.groups.vmail.gid}";
      virtual_transport = "virtual";
      local_transport = "virtual";
      local_recipient_maps = "$virtual_mailbox_maps";
    };
    virtual = ''
      root@mail-kopatz.duckdns.org kopatz@mail-kopatz.duckdns.org
      mailer-daemon@mail-kopatz.duckdns.org kopatz@mail-kopatz.duckdns.org
      postmaster@mail-kopatz.duckdns.org kopatz@mail-kopatz.duckdns.org
      nobody@mail-kopatz.duckdns.org kopatz@mail-kopatz.duckdns.org
      hostmaster@mail-kopatz.duckdns.org kopatz@mail-kopatz.duckdns.org
      usenet@mail-kopatz.duckdns.org kopatz@mail-kopatz.duckdns.org
      news@mail-kopatz.duckdns.org kopatz@mail-kopatz.duckdns.org
      webmaster@mail-kopatz.duckdns.org kopatz@mail-kopatz.duckdns.org
      www@mail-kopatz.duckdns.org kopatz@mail-kopatz.duckdns.org
      ftp@mail-kopatz.duckdns.org kopatz@mail-kopatz.duckdns.org
      abuse@mail-kopatz.duckdns.org kopatz@mail-kopatz.duckdns.org
    '';
    mapFiles = {
      "virtual-map" = pkgs.writeText "postfix-virtual" ''
        kopatz@mail-kopatz.duckdns.org mail-kopatz.duckdns.org/kopatz/
        test@mail-kopatz.duckdns.org mail-kopatz.duckdns.org/test/
      '';
    };
  };
  services.dovecot2 = {
    enable = true;
    enableImap = true;
    enablePAM = false;
    configFile = pkgs.writeText "dovecot.conf" ''
      default_internal_user = ${config.services.dovecot2.user}
      default_internal_group = ${config.services.dovecot2.group}
      passdb {
        driver = passwd-file
        args = scheme=CRYPT username_format=%u /etc/dovecot-users
      }

      userdb {
        driver = passwd-file
        args = username_format=%u /etc/dovecot-users
        default_fields = uid=vmail gid=vmail home=/home/vmail/%u
      }
      mail_location = maildir:/data/vmail/mail-kopatz.duckdns.org/%n

      ssl = no
      disable_plaintext_auth = no
      auth_mechanisms = plain
    '';
  };
  environment.etc."dovecot-users".text = tmp_dovecot_passwords;

  # 8888 = scheibenmeister skip button
  # 25 = stmp -> postfix
  # 143 = imap -> dovecot
  networking.firewall.allowedTCPPorts = [ 25565 25566 8888 25 143 ];
  networking.hostName = "server-vm"; # Define your hostname.

  #services.murmur = {
  #  enable = true;
  #  openFirewall = true;
  #};

  #fileSystems."/" = {
  #  device = "/dev/disk/by-label/nixos";
  #  fsType = "ext4";
  #  options = [ "defaults" "noatime" ];
  #};
  #fileSystems."/boot" =
  #{ device = "/dev/disk/by-label/ESP";
  #    fsType = "vfat";
  #};
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/d117419d-fce9-4d52-85c7-e3481feaa22a";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" "nofail" ];
  };
  fileSystems."/1tbssd" = {
    device = "/dev/disk/by-uuid/801d9217-9c38-4ca8-914e-e31361603892";
    fsType = "ext4";
    options = [ "defaults" "nofail" "noatime" ];
  };


  # Configure console keymap
  console.keyMap = "us";

  system.stateVersion = "24.11"; # Did you read the comment?
}
