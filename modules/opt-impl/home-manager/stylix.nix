{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.stylix;
  base16 = config.stylix.base16Scheme;
in
{
  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      targets = {
        hyprlock.enable = false;
        hyprland.enable = false;
        hyprpaper.enable = false;
        waybar = {
          enable = true;
          addCss = false;
        };
        gtk = {
          flatpakSupport.enable = true; # edits ~/.themes/adw-gtk3
          # Stylix sets accent_fg_color to the background base, assuming a filled
          # accent button. Apps that draw the default button outlined then show
          # dark-on-dark text, so override it with the light foreground base.
          extraCss = ''
            @define-color accent_fg_color #${base16.base05};

          '';
        };
      };
    };

    # Stylix only ships colors; it never states the light/dark preference.
    # GTK 4.20+/libadwaita pick their palette from the color scheme instead of
    # from Stylix's @define-color overrides, so without this every GTK app
    # renders light. Writes gtk-application-prefer-dark-theme (GTK 3),
    # gtk-interface-color-scheme (GTK 4) and the matching dconf key.
    gtk.colorScheme = lib.mkIf (config.stylix.polarity != "either") config.stylix.polarity;

    wayland.windowManager.hyprland.settings = lib.mkIf config.custom.graphical.hyprland.enable {
      config.general.col.active_border = lib.mkForce {
        colors = [
          "rgb(${base16.base07})"
          "rgb(${base16.base04})"
        ];
        angle = 45;
      };
    };
  };
}
