{ pkgs, config, ...}:
{
  imports = [
    ./audio.nix
    ./code.nix
    ./emulators.nix
    ./gamemode.nix
    ./games.nix
    ./gnome.nix
    ./ime.nix
    ./lxqt.nix
    ./noise-supression.nix
    ./obs.nix
    ./openrgb.nix
    ./plasma.nix
    ./shared.nix
  ];
}
