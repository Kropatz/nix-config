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

  options = {
    custom.graphical.sddm.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable sddm";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.sddm-astronaut.override { embeddedTheme = "pixel_sakura"; })
      pkgs.qylock
    ];
    environment.etc."sddm.conf.d/virtualkeyboard.conf".text = ''
      InputMethod=
    '';
    environment.sessionVariables = {
      QML_IMPORT_PATH = [
        "${pkgs.qt6.qtmultimedia}/lib/qt-6/qml"
        "${pkgs.kdePackages.qt5compat}/lib/qt-6/qml"
      ];
      QML2_IMPORT_PATH = [
        "${pkgs.qt6.qtmultimedia}/lib/qt-6/qml"
        "${pkgs.kdePackages.qt5compat}/lib/qt-6/qml"
      ];
    };
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
          extraPackages = [
            (pkgs.sddm-astronaut.override { embeddedTheme = "pixel_sakura"; })
            pkgs.qylock
          ];
          #wayland.enable = true;
          #sddm.theme = "breeze";
        };
      };
    };
  };
}
