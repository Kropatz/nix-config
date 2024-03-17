{ config, pkgs, ... }:

{
  services.xserver = {
    xkb.layout = "at";
    xkb.variant = "";
    enable = true;
    displayManager.sddm.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
}
