{ config, pkgs, lib, ... }:
let basePath = "/synced";
in {
  systemd.tmpfiles.rules =
    [ "d ${basePath} 0700 ${config.mainUser.name} users -" ];

  # check device id: syncthing cli --gui-address=/synced/gui-socket --gui-apikey=<key> show system
  environment.systemPackages = with pkgs; [ syncthing ];

  services.syncthing = {
    enable = true;
    dataDir = basePath;
    user = config.mainUser.name;
    group = "users";
    guiAddress = "${basePath}/gui-socket";
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      options.urAccepted = -1;
      options.relaysEnabled = false;
      options.globalAnnounceEnabled = false;
      options.crashReportingEnabled = false;

      devices = {
        kop-pc = {
          id =
            "DZKIUS7-WCGTYEV-4OKVSZU-MIVL2NC-N45AKZL-ABT3VN2-I7RXUMF-RF4CYAU";
          addresses = [ "tcp://192.168.0.11" ];
        };
        server = {
          id =
            "HZUUQEQ-JOKYHTU-AVFVC3U-7KUAXVC-QY3OJTF-HGU7RZ3-5HA5TOE-VT4FNQB";
          addresses = [ "tcp://192.168.0.6" "tcp://192.168.2.1" ];
        };
        mini-pc = {
          id =
            "NKRWOR6-2YNLVY5-GH6TG7T-V3M4VHD-OFS4XR3-Q45CALD-JVSIBKU-JZBGRQ3";
          addresses = [ "tcp://192.168.0.10" "tcp://192.168.2.1" ];
        };
        mini-pc-proxmox = {
          id =
            "FK3DW4B-6Y7C25O-IDBSOMV-GOUSWZW-KQR7ELS-QUKS4UR-AFZXLZE-67QJXAX";
          addresses = [ "tcp://192.168.0.10" "tcp://192.168.2.1" ];
        };
        laptop = {
          id =
            "5T6Y3WO-FOQYYFQ-5MLNDSZ-7APIDUG-6KM2ZZM-RTRXMWX-MCZKLMH-BYNDJAQ";
          addresses = [ "tcp://192.168.2.22" ];
        };
        phone = {
          id =
            "XFQ7MV6-MKBYQXH-WGYVQUB-BYJJPFJ-HJTNZEP-PXWAMYY-DMADWSU-PQOTVAI";
          addresses = [ "tcp://192.168.0.15" "tcp://192.168.2.20" ];
        };
      };
      folders."${basePath}/default" = {
        id = "default";
        devices =
          [ "kop-pc" "server" "laptop" "mini-pc" "mini-pc-proxmox" "phone" ];
        ignorePerms = false;
      };

      folders."${basePath}/books" = {
        id = "books";
        devices = [ "kop-pc" "server" "laptop" "mini-pc" "mini-pc-proxmox" ];
      };

      folders."${basePath}/fh" = {
        id = "fh";
        devices = [ "kop-pc" "server" "laptop" "mini-pc" "mini-pc-proxmox" ];
      };

      folders."${basePath}/work_drive" = {
        id = "work_drive";
        devices = [ "kop-pc" "server" "laptop" "mini-pc" "mini-pc-proxmox" ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8384 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];
}
