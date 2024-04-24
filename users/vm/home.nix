{ config, pkgs, inputs, ...}:
{
  home = {
    stateVersion = "23.05";
  };

  imports = [
    ../../home-manager/nvim.nix
    ../../home-manager/zsh.nix
    ../../home-manager/hyprland-settings.nix
    inputs.nix-colors.homeManagerModule
  ];
}
