{ config, pkgs, lib, inputs, ... }:
with lib;
let cfg = config.custom.services.caldav;
in {
  options.custom.services.caldav = {
    enable = mkEnableOption "Enables caldav server";
  };
  config = lib.mkIf cfg.enable {
    age.secrets.radicale-users = {
      file = ../../secrets/radicale.age;
      owner = "radicale";
    };
    services.radicale = {
      enable = true;
      settings = {
        server = { hosts = [ "192.168.2.1:5232" "192.168.0.10:5232" ]; };
        #server = { hosts = [ "192.168.0.11:5232" ]; };
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.age.secrets.radicale-users.path;
          htpasswd_encryption = "bcrypt";
        };
        storage = { filesystem_folder = "/var/lib/radicale/collections"; };
      };
    };
  };
}
