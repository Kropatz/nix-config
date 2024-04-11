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
    ../../home-manager/zsh.nix
    ../../home-manager/gtk-theme.nix
    ../../home-manager/direnv.nix
    ../../home-manager/lf.nix
    ../../home-manager/kitty.nix
    ../../home-manager/rofi.nix
    ../../home-manager/kde-path.nix
    ../../home-manager/firefox
    inputs.nix-colors.homeManagerModule
  ];

  home.file.".gitconfig" = {
    enable = true;
    source = ./.gitconfig;
    target = ".gitconfig";
  };
  home.file.".gitconfig-gitea" = {
    enable = true;
    source = ./.gitconfig-gitea;
    target = ".gitconfig-gitea";
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

  colorScheme = import ../../home-manager/themes/yorha/colors.nix;
}
