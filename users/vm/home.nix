{ config, pkgs, inputs, ...}:
{
  home = {
    stateVersion = "23.05";
  };

  imports = [
    ../../home-manager/nvim.nix
    ../../home-manager/zsh.nix
    inputs.nix-colors.homeManagerModule
  ];
}
