{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.custom.services.fileshelter;
in
{
  options.custom.services.fileshelter = {
    enable = mkEnableOption "Enables fileshelter";
  };
  config = lib.mkIf cfg.enable {
    users.users.fileshelter = {
        isSystemUser = true;
        group = "fileshelter";
    };
    users.groups.fileshelter = {};
    age.secrets.fileshelter-conf = {
        file = ../../secrets/fileshelter-conf.age;
        owner = "fileshelter";
    };
    virtualisation.oci-containers.containers = {
      "fileshelter" = {
        user = "fileshelter";
        autoStart = true;
        image = "epoupon/fileshelter";
        ports = [
          "127.0.0.1:5091:5091"
        ];
        volumes = [
          "/data/fileshelter:/var/fileshelter"
          "/run/agenix/fileshelter.conf:/etc/fileshelter.conf"
        ];
      };
    };
  };
}
