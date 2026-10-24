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
    zelIp = lib.mkOption {
      type = lib.types.str;
      default = "192.168.0.13";
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

    nginx = {
      allowOnlyInternalIps = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = ''
            allow 192.168.0.0/24;
            allow 192.168.2.0/24;
            deny all;
        '';
      };
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

      gitea = lib.mkOption {
        type = lib.types.int;
        default = 2009;
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
      gitea = lib.mkOption {
        type = lib.types.int;
        default = 2009;
      };
    };
  };
}
