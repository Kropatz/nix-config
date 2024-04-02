{ config, pkgs, ...}: 
{
  services.xserver = {
    xkb.layout = config.mainUser.layout; 
    xkb.variant = config.mainUser.variant;
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.lxqt.enable = true;
  };
}
