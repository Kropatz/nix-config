{ config, pkgs, inputs, lib, ... }:
with config.stylix.fonts;
let
  mkLiteral = name: "${name}";
  mkRgba = opacity: color:
    let
      c = config.lib.stylix.colors;
      r = c."${color}-rgb-r";
      g = c."${color}-rgb-g";
      b = c."${color}-rgb-b";
    in "rgba ( ${r}, ${g}, ${b}, ${opacity} % )";
  mkRgb = mkRgba "100";
  rofiOpacity =
    builtins.toString (builtins.ceil (config.stylix.opacity.popups * 100));
  rofiTheme = {
    background = mkRgba rofiOpacity "base00";
    lightbg = mkRgba rofiOpacity "base01";
    red = mkRgba rofiOpacity "base08";
    blue = mkRgba rofiOpacity "base0D";
    lightfg = mkRgba rofiOpacity "base06";
    foreground = mkRgba rofiOpacity "base05";
    transparent = mkRgba "0" "base00";

    background-color = mkLiteral "rgba ( 0, 0, 0, 0 % )";
    separatorcolor = mkLiteral "@transparent";
    border-color = mkLiteral "@foreground";
    selected-normal-foreground = mkLiteral "@foreground";
    selected-normal-background = mkLiteral "@lightbg";
    selected-active-foreground = mkLiteral "@background";
    selected-active-background = mkLiteral "@blue";
    selected-urgent-foreground = mkLiteral "@background";
    selected-urgent-background = mkLiteral "@red";
    normal-foreground = mkLiteral "@foreground";
    normal-background = mkLiteral "@transparent";
    active-foreground = mkLiteral "@blue";
    active-background = mkLiteral "@background";
    urgent-foreground = mkLiteral "@red";
    urgent-background = mkLiteral "@background";
    alternate-normal-foreground = mkLiteral "@foreground";
    alternate-normal-background = mkLiteral "@transparent";
    alternate-active-foreground = mkLiteral "@blue";
    alternate-active-background = mkLiteral "@background";
    alternate-urgent-foreground = mkLiteral "@red";
    alternate-urgent-background = mkLiteral "@background";

    # Text Colors
    base-text = mkRgb "base05";
    selected-normal-text = mkRgb "base01";
    selected-active-text = mkRgb "base00";
    selected-urgent-text = mkRgb "base00";
    normal-text = mkRgb "base05";
    active-text = mkRgb "base0D";
    urgent-text = mkRgb "base08";
    alternate-normal-text = mkRgb "base05";
    alternate-active-text = mkRgb "base0D";
    alternate-urgent-text = mkRgb "base08";
  };
in {
  home.file.".config/rofi" = {
    enable = true;
    recursive = true;
    source = ../../.config/rofi;
  };

  home.file.".config/rofi/rofi_stylix_colors.rasi" = {
    enable = true;
    text = ''
      * {
        ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name}: ${value};") rofiTheme)}
      }
    '';
  };
}
