{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.custom.services.fileshelter;
in
{
  options.custom.services.fileshelter = {
    enable = mkEnableOption "Enables fileshelter";
    uid = mkOption {
      default = 20000;
      description = "uid of the fileshelter user";
    };
  };
  config = lib.mkIf cfg.enable {
    users.users.fileshelter = {
        isSystemUser = true;
        uid = cfg.uid;
        group = "fileshelter";
    };
    users.groups.fileshelter = {};
    age.secrets.fileshelter-conf = {
        file = ../../secrets/fileshelter-conf.age;
        owner = "fileshelter";
    };
    systemd.tmpfiles.rules = [
        "d /data/fileshelter 0770 fileshelter fileshelter -"
    ];
    custom.misc.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers = {
      "fileshelter" = {
        autoStart = true;
        user = toString cfg.uid;
        image = "epoupon/fileshelter";
        ports = [
          "127.0.0.1:5091:5091"
        ];
        volumes = [
          "/data/fileshelter:/var/fileshelter"
        ];
        extraOptions = [
          "--mount=type=bind,source=/run/agenix/fileshelter-conf,destination=/etc/fileshelter.conf"
        ];
      };
    };
  };
}

