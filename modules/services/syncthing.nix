{ config, pkgs, lib, inputs, ... }:
let cfg = config.custom.services.syncthing;
in {
  options.custom.services.syncthing = {
    enable = lib.mkEnableOption "Enables syncthing";
    basePath = lib.mkOption {
      type = with lib.types; string;
      default = "/home/${config.mainUser.name}/synced";
      description = "Base path for syncthing data";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules =
      [ "d ${cfg.basePath} 0700 ${config.mainUser.name} users -" ];

    # check device id: syncthing cli --gui-address=/synced/gui-socket --gui-apikey=<key> show system
    environment.systemPackages = with pkgs; [ syncthing ];

    services.syncthing = {
      enable = true;
      dataDir = cfg.basePath;
      user = config.mainUser.name;
      group = "users";
      guiAddress = "${cfg.basePath}/gui-socket";
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
              "JKZGIMH-4YWAMUN-SQZBKFY-BVLEFP4-NBNZP2T-R2LSLSN-RVSL7BH-3AFIFAB";
            addresses = [ "tcp://192.168.0.15" "tcp://192.168.2.20" ];
          };
        };
        folders."default" = {
          id = "default";
          path = "${cfg.basePath}/default";
          devices =
            [ "kop-pc" "server" "laptop" "phone" ];
          ignorePerms = false;
        };

        folders."books" = {
          id = "books";
          path = "${cfg.basePath}/books";
          devices = [ "kop-pc" "server" "laptop" ];
        };

        folders."fh" = {
          id = "fh";
          path = "${cfg.basePath}/fh";
          devices = [ "kop-pc" "server" "laptop" ];
        };

        folders."work_drive" = {
          id = "work_drive";
          path = "${cfg.basePath}/work_drive";
          devices = [ "kop-pc" "server" "laptop" ];
        };

        folders."no_backup" = {
          id = "no_backup";
          path = "${cfg.basePath}/no_backup";
          devices = [ "kop-pc" "server" "laptop" ];
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 8384 22000 ];
    networking.firewall.allowedUDPPorts = [ 22000 21027 ];
  };
}
