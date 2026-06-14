{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.sway;
in
{

  options = {
    custom.graphical.sway.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable sway window manager";
    };
  };

}
