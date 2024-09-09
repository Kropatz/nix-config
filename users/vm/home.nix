{ config, pkgs, inputs, ... }: {
  home = { stateVersion = "23.05"; };

  imports = [
    #../../home-manager/nvim.nix
    ../../home-manager/zsh
    #../../home-manager/rofi.nix
    #../../home-manager/kitty.nix
    #../../home-manager/i3.nix
    #inputs.nixvim.homeManagerModules.nixvim
    #inputs.nix-colors.homeManagerModule
  ];

}
