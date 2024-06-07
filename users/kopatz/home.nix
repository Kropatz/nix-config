{ osConfig, config, pkgs, inputs, lib, ...}:
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
    ../../home-manager/code.nix
    ../../home-manager/fastfetch.nix
    ../../home-manager/direnv.nix
    ../../home-manager/firefox
    ../../home-manager/gitconfig.nix
    ../../home-manager/hyprland
    #../../home-manager/kde-path.nix
    ../../home-manager/kitty.nix
    ../../home-manager/lf.nix
    ../../home-manager/nixvim
    ../../home-manager/rofi.nix
    ../../home-manager/dunst.nix
    #../../home-manager/theme.nix
    ../../home-manager/zsh.nix
    ../../home-manager/i3.nix
    inputs.nixvim.homeManagerModules.nixvim
    inputs.nix-colors.homeManagerModule
  ] ++ lib.optional osConfig.custom.graphical.i3.enable ../../home-manager/i3.nix; # need this hack because i3 uses stylix, and it errors otherwise

  colorScheme = import ../../home-manager/themes/yorha/colors.nix;
}
