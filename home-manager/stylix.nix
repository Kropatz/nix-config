{
  osConfig,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = osConfig.custom.graphical.stylix;
  base16 = config.stylix.base16Scheme;
in
{
  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      targets = {
        hyprlock.enable = true;
        hyprland.enable = false;
        hyprpaper.enable = false;
        waybar = {
          enable = true;
          addCss = false;
        };
        gtk.flatpakSupport.enable = true; # edits ~/.themes/adw-gtk3
      };
    };

    wayland.windowManager.hyprland.settings = lib.mkIf osConfig.custom.graphical.hyprland.enable {
      env = [ "GTK_THEME,adw-gtk3" ];
      general."col.active_border" = lib.mkForce "rgb(${base16.base07}) rgb(${base16.base04}) 45deg";
    };
  };
}
