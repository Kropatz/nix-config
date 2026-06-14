{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.sddm;
in
{

  options = {
    custom.graphical.sddm.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable sddm";
    };
  };

}
