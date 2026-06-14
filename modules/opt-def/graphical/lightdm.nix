{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.lightdm;
in
{

  options = {
    custom.graphical.lightdm.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable lightdm";
    };
  };

}
