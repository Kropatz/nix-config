{ config, pkgs, inputs, ...}:
{
  home = {
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.05";
  };

  imports = [
    ../../home-manager/nvim.nix
    ../../home-manager/code.nix
    #../../home-manager/browser.nix extensions dont work with ungoogled chromium sadly
    ../../home-manager/zsh.nix
    ../../home-manager/gtk-theme.nix
    ../../home-manager/direnv.nix
    ../../home-manager/lf.nix
    ../../home-manager/kitty.nix
    ../../home-manager/rofi.nix
    ../../home-manager/kde-path.nix
    inputs.nix-colors.homeManagerModule
  ];

  colorScheme = import ../../home-manager/themes/yorha/colors.nix;
}
