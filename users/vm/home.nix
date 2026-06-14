{
  config,
  pkgs,
  inputs,
  ...
}:
{
  home = {
    stateVersion = "23.05";
  };

  imports = [
    ../../modules/opt-impl/home-manager/default.nix
    ../../modules/opt-impl/home-manager/zsh
    #../../home-manager/nvim.nix
    #../../home-manager/rofi.nix
    #../../home-manager/kitty.nix
    #../../home-manager/i3.nix
    #inputs.nixvim.homeManagerModules.nixvim
  ];

}
