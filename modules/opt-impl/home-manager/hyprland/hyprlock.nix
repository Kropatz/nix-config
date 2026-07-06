{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    programs.hyprlock.enable = true;
    home.file.".config/hypr/hyprlock.conf" = {
      recursive = true;
      source = ../../../../.config/hypr/hyprlock.conf;
    };
    /*
TODO:
In file specify @colorXX@ variables to be replaced with stylix colors, e.g.:
source = pkgs.replaceVars ../../../../.config/hypr/hyprlock.conf {
  colorXX = stylix-baseXX-color;
};
*/
  };
}
