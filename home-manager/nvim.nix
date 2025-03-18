{ config, pkgs, inputs, ... }:
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
      gcc
      ripgrep
      fd
      cmake
      pyright
      nodePackages.eslint
      ccls
      nodejs_22
      go
    ];
  };
}
