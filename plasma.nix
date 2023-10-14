{ config, pkgs, ... }:

{

  imports =
  [
	./main.nix
  ];

  services.xserver = {
    layout = "at";
    xkbVariant = "";
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };
}
