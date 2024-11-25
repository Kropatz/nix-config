{lib,  config, pkgs, ...}:
with lib;
let
  cfg = config.custom.graphical.xfce;
in
{
  options.custom.graphical.xfce = {
    enable = mkEnableOption "Enables lxqt";
  };
  
  config = mkIf cfg.enable {
    services.xserver = {
      xkb.layout = config.mainUser.layout; 
      xkb.variant = config.mainUser.variant;
      enable = true;
      desktopManager.xfce.enable = true;
    };
  };
}
