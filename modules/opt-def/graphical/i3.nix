{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.i3;
in
{

  options = {
    custom.graphical.i3.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable i3 window manager";
    };
  };

}
