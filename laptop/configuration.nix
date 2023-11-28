{ config, pkgs, ... }:

{

  imports =
  [
        ./main.nix
        ./hyperland.nix
        ./gnome.nix
  ];

  services.xserver = {
    layout = "at";
    xkbVariant = "";
    enable = true;
    displayManager.gdm.enable = true;
  };
}
