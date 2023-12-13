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
      programs.kitty = {
        enable = true;
        settings = {
          foreground = "#${config.colorScheme.colors.base05}";
          background = "#${config.colorScheme.colors.base00}";
          # ...
        };
    };

  imports = [
    ../../home-manager/nvim.nix
    ../../home-manager/zsh.nix
    ../../home-manager/direnv.nix
    inputs.nix-colors.homeManagerModule
  ];

  colorScheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
}
