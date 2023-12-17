{ config, pkgs, lib, ... }:

{

  imports =
  [
        ./main.nix
        ./gnome.nix
  ];

  services.xserver = {
    layout = lib.mkForce "at";
    xkbVariant = lib.mkForce "";
    enable = true;
    displayManager.gdm.enable = true;
  };
}
