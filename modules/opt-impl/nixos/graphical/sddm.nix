{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.sddm;
in
{

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.sddm-astronaut.override { embeddedTheme = "pixel_sakura"; })
      pkgs.qylock
    ];
    environment.etc."sddm.conf.d/virtualkeyboard.conf".text = ''
      InputMethod=
    '';
    services = {
      displayManager = {
        generic = {
          environment = {
            QML_XHR_ALLOW_FILE_READ = "1";
          };
        };
        sddm = {
          enable = true;
          theme = "nier-automata";
          extraPackages = with pkgs; [
            (pkgs.sddm-astronaut.override { embeddedTheme = "pixel_sakura"; })
            pkgs.qylock
            kdePackages.qt5compat # provides Qt5Compat.GraphicalEffects used by qylock themes
            kdePackages.qtmultimedia # for video backgrounds
            kdePackages.qtsvg
          ];
          #wayland.enable = true;
          #sddm.theme = "breeze";
        };
      };
    };
  };
}
