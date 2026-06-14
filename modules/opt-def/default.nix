{ pkgs, config, ... }:
{
  imports = [
    ./hardware
    ./misc
    ./nix
    ./services
    ./graphical
    ./vars.nix
    ./networking
  ];
}
