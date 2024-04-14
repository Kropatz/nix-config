{ config, pkgs, lib, vars, ... }:
let
  basePath = "/synced";
in 
{
  systemd.tmpfiles.rules = [
      "d ${basePath} 0700 ${config.mainUser.name} users -"
  ];
  
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
          id = "DZKIUS7-WCGTYEV-4OKVSZU-MIVL2NC-N45AKZL-ABT3VN2-I7RXUMF-RF4CYAU";
          adresses = [ "tcp://192.168.0.11:51820"];
        };
        server = {
          id = "HZUUQEQ-JOKYHTU-AVFVC3U-7KUAXVC-QY3OJTF-HGU7RZ3-5HA5TOE-VT4FNQB";
          adresses = [ "tcp://192.168.0.6:51820" "tcp//192.168.2.1:51820" ];
        };
      };

      folders."${basePath}/default" = {
        id = "default";
        devices = [ "kop-pc" "server" ];
        ignorePerms = false;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8384 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];
}
