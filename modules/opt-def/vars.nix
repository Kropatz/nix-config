{
  lib,
  ...
}:
let
  name = "vars";
in
{
  options.custom.${name} = {
    serverIp = lib.mkOption {
      type = lib.types.str;
      default = "192.168.0.10";
    };
    serverVpnIp = lib.mkOption {
      type = lib.types.str;
      default = "192.168.2.1";
    };
    exposedServerIp = lib.mkOption {
      type = lib.types.str;
      default = "192.168.0.22";
    };
    hostIp = lib.mkOption {
      type = lib.types.str;
      default = "192.168.0.20";
    };

    internalCidr = lib.mkOption {
      type = lib.types.str;
      default = "192.168.0.0/24";
    };

    ports = {
      dtrack = lib.mkOption {
        type = lib.types.int;
        default = 4005;
      };
      service-dashboard = lib.mkOption {
        type = lib.types.int;
        default = 4006;
      };
    };
    uids = {
      jakob-nas = lib.mkOption {
        type = lib.types.int;
        default = 2005;
      };

      ente = lib.mkOption {
        type = lib.types.int;
        default = 2006;
      };

      netbird = lib.mkOption {
        type = lib.types.int;
        default = 2007;
      };

      katze = lib.mkOption {
        type = lib.types.int;
        default = 2008;
      };
    };
    gids = {
      torrent = lib.mkOption {
        type = lib.types.int;
        default = 2004;
      };
      jakob-nas = lib.mkOption {
        type = lib.types.int;
        default = 2005;
      };
      ente = lib.mkOption {
        type = lib.types.int;
        default = 2006;
      };
      netbird = lib.mkOption {
        type = lib.types.int;
        default = 2007;
      };
      katze = lib.mkOption {
        type = lib.types.int;
        default = 2008;
      };
    };
  };
}
