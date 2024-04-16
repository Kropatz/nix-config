{lib,  config, pkgs, ...}:
with lib;
let
  cfg = config.kop.graphical.lxqt;
in
{
  options.kop.graphical.lxqt = {
    enable = mkEnableOption "Enables lxqt";
  };
  
  config = mkIf cfg.enable {
    services.xserver = {
      xkb.layout = config.mainUser.layout; 
      xkb.variant = config.mainUser.variant;
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.lxqt.enable = true;
    };
  };
}
