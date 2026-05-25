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

    gids = {
      torrent = lib.mkOption {
        type = lib.types.int;
        default = 2004;
      };
    };
  };
}
