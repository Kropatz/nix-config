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
    environment.systemPackages = [ (pkgs.sddm-astronaut.override { embeddedTheme = "pixel_sakura"; }) ];
    services = {
      displayManager.sddm = {
        enable = true;
        theme = "sddm-astronaut-theme";
        extraPackages = [ (pkgs.sddm-astronaut.override { embeddedTheme = "pixel_sakura"; }) ];
        #wayland.enable = true;
        #sddm.theme = "breeze";
      };
    };
  };
}
