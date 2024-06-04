{ pkgs, config, lib, ...}:
{

  imports = [
    ./audio.nix
    ./code.nix
    ./code-android.nix
    ./awesome.nix
    ./emulators.nix
    ./i3.nix
    ./gamemode.nix
    ./games.nix
    ./gnome.nix
    ./gnome-settings.nix
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
