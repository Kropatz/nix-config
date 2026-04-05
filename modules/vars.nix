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
    hostIp = lib.mkOption {
      type = lib.types.str;
      default = "192.168.0.20";
    };
  };
}
