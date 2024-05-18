{ lib, config, pkgs, ... }:
with lib;
let cfg = config.custom.graphical.stylix;
in {
  options.custom.graphical.stylix = {
    enable = mkEnableOption "Enables stylix";
  };

  # https://danth.github.io/stylix/options/nixos.html
  config =
    let nerdfonts = pkgs.nerdfonts.override { fonts = [ "Hack" "Noto" ]; };
    in mkIf cfg.enable {
      stylix = {
        polarity = "dark";
        #image = ./yuyukowallpaper1809.png;
        #base16Scheme = ../../home-manager/themes/yorha/scheme.yml;
        base16Scheme =
          "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
        cursor = {
          size = 24;
          name = "breeze_cursors";
          package = pkgs.libsForQt5.breeze-gtk;
        };
        opacity = {
          applications = 0.7;
          desktop = 0.7;
          terminal = 0.7;
        };
        fonts = {
          serif = config.stylix.fonts.sansSerif;
          sansSerif = {
            package = pkgs.noto-fonts;
            name = "Noto Sans";
          };
          sizes = {
            applications = 12;
            desktop = 10;
            popups = 10;
            terminal = 12;
          };
          monospace = {
            package = nerdfonts;
            name = "Hack";
          };
        };
      };
    };
}
