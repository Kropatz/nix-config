{ user, pkgs, ... }:
{
  home-manager.users.${user} = { pkgs, ...}: {
    home.file.".config/nvim" = {
      enable = true;
      recursive = true;
      source = ../../../.config/nvim;
      target = ".config/nvim";
    };
    programs.neovim = {
      enable = true;
      extraPackages = with pkgs; [
        rnix-lsp
        gcc
        ripgrep
        fd
        cmake
        nodePackages.pyright
        nodePackages.eslint
        ccls
      ];
    };
  };
}
