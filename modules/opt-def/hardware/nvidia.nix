{
  lib,
  config,
  pkgs,
  inputs,
  pkgsVersion,
  ...
}:
let
  cfg = config.custom.hardware.nvidia;
in
{
  options.custom.hardware.nvidia = {
    enable = lib.mkEnableOption "Enables nvidia gpus";
    powerLimit = {
      enable = lib.mkEnableOption "Increase GPU power limit";
      wattage = lib.mkOption {
        type = lib.types.int;
        default = 300;
        description = "The power limit to set the GPU to";
      };
    };
    clock = {
      enable = lib.mkEnableOption "Set GPU clocks";
      min = lib.mkOption {
        type = lib.types.int;
        description = "The minimum GPU clock to set";
      };
      max = lib.mkOption {
        type = lib.types.int;
        description = "The maximum GPU clock to set";
      };
      offset = lib.mkOption {
        type = lib.types.int;
        description = "The GPU clock offset to set";
      };
    };
  };
}
