{ pkgs, config, lib, ... }:
{

  imports = [
    ./audio.nix
    ./lightdm.nix
    ./code.nix
    ./sddm.nix
    ./code-android.nix
    ./awesome.nix
    ./emulators.nix
    ./i3.nix
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
    ./nightlight.nix
    ./xfce.nix
    ./basics.nix
    ./sway.nix
    ./gpu-screen-recorder-ui.nix
  ];
}
