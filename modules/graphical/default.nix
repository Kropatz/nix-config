{ pkgs, config, lib, ...}:
{

  imports = [
    ./audio.nix
    ./code.nix
    ./emulators.nix
    ./gamemode.nix
    ./games.nix
    ./gnome.nix
    ./hyprland.nix
    ./ime.nix
    ./lxqt.nix
    ./noise-supression.nix
    ./obs.nix
    ./openrgb.nix
    ./plasma.nix
    #./stylix.nix
    #./cosmic.nix
    ./shared.nix
  ];
}
