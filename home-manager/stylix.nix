{ osConfig, pkgs, config, lib, ... }:
let cfg = osConfig.custom.graphical.stylix;
in {
  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      targets = {
        hyprlock.enable = false;
        hyprland.enable = false;
        waybar.enable = false;
        gtk.flatpakSupport.enable = true; #edits ~/.themes/adw-gtk3
      };
    };

    wayland.windowManager.hyprland.settings.env = lib.mkIf osConfig.custom.graphical.hyprland.enable [
      "GTK_THEME,adw-gtk3"
    ];
  };
}
