{ config, pkgs, lib, inputs, ... }:
{

  networking.firewall.allowedTCPPorts = [ 5000 ];
  age.secrets.kavita = {
    file = ../secrets/kavita.age;
    owner = "kavita";
    group = "kavita";
  };
  services.kavita = {
    enable = true;
    user = "kavita";
    port = 5000;
    dataDir = "/mnt/250ssd/kavita";
    tokenKeyFile = config.age.secrets.kavita.path;
  };
  #todo: base url needs new kavita version
  systemd.services.kavita = {
      preStart = ''
        umask u=rwx,g=rx,o=
        cat > "/mnt/250ssd/kavita/config/appsettings.json" <<EOF
        {
          "TokenKey": "$(cat ${config.age.secrets.kavita.path})",
          "Port": 5000,
          "BaseUrl" : "/books",
          "IpAddresses": "${lib.concatStringsSep "," ["0.0.0.0" "::"]}"
        }
        EOF
      '';
  };
}
