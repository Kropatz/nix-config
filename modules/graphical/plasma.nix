{ config, pkgs, ... }:

{
  services.xserver = {
    xkb.layout = config.mainUser.layout; 
    xkb.variant = config.mainUser.variant;
    enable = true;
    displayManager.sddm.enable = true;
    #displayManager.sddm.wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
}
