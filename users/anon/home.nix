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
    ../../home-manager/zsh.nix
    ../../home-manager/direnv.nix
    inputs.nix-colors.homeManagerModule
  ];

  home.file.".gitconfig" = {
    enable = true;
    source = ./.gitconfig;
    target = ".gitconfig";
  };
  home.file.".gitconfig-github" = {
    enable = true;
    source = ./.gitconfig-github;
    target = ".gitconfig-github";
  };
  home.file.".gitconfig-selfhosted" = {
    enable = true;
    source = ./.gitconfig-selfhosted;
    target = ".gitconfig-selfhosted";
  };
  home.file.".gitconfig-gitlabfh" = {
    enable = true;
    source = ./.gitconfig-gitlabfh;
    target = ".gitconfig-gitlabfh";
  };
  home.file.".gitconfig-evolit" = {
    enable = true;
    source = ./.gitconfig-evolit;
    target = ".gitconfig-evolit";
  };

  colorScheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
}
