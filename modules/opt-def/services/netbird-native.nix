{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "netbird-native";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables netbird-native";

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/netbird";
      description = "Directory to store netbird data";
    };
  };
}
