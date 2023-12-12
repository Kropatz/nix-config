{ config, pkgs, inputs, ...}:
{
    home.file.".config/nvim" = {
      enable = true;
      recursive = true;
      source = ../.config/nvim;
      target = ".config/nvim";
    };
    programs.neovim = {
      enable = true;
      defaultEditor = true;
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
}
