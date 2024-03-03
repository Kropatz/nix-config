{ config, pkgs, ... }:

{
  services.xserver = {
    layout = "at";
    xkbVariant = "";
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
  };
}
