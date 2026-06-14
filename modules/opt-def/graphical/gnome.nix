{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.gnome;
in
{
  options.custom.graphical.gnome = {
    enable = mkEnableOption "Enables gnome";
  };

}
