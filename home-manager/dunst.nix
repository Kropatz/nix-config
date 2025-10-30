{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  enable = osConfig.custom.graphical.i3.enable || osConfig.custom.graphical.hyprland.enable;
in
{
  config = lib.mkIf enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          width = "(0,1000)";
          height = "1000";
          offset = "0x0";
          origin = "bottom-center";
          transparency = -1;
          frame_color = "#1a1c1b";
          font = lib.mkDefault "Monospace 8";
          monitor = 1;
        };

        urgency_normal = {
          background = lib.mkDefault "#1a1c1b";
          foreground = lib.mkDefault "#eceff1";
          timeout = 10;
        };
      };
    };
  };
}
