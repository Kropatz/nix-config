{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.graphical.stylix;
in
{
  options.custom.graphical.stylix = with lib; {
    enable = mkEnableOption "Enables stylix";
    image = mkOption {
      type = types.path;
      default = ../../../wallpaper/tsukasa.jpg;
      description = ''
        The wallpaper to use.
      '';
    };
    base16Scheme = mkOption {
      type =
        with lib.types;
        nullOr (oneOf [
          path
          lines
          attrs
        ]);
      default = null;
      description = ''
        The base16 scheme to use.
      '';
    };
    override = mkOption {
      type = types.attrs;
      #default = {};
      default = {
        base08 = "ed8796"; # red
        base09 = "f5a97f"; # peach
        base0A = "eed49f"; # yellow
        base0B = "a6da95"; # green
        base0C = "8bd5ca"; # teal
        base0D = "8aadf4"; # blue
        base0E = "c6a0f6"; # mauve
        base0F = "f0c6c6"; # flamingo
      };
      description = ''
        Override the generated colors.
      '';
    };
  };

  # https://danth.github.io/stylix/options/nixos.html
}
