{ lib, pkgs, ... }:
# https://nix-community.github.io/nixvim/NeovimOptions/index.html
let
  args = { inherit lib pkgs; };

  importFile = file:
    let config = import file;
    in if builtins.isFunction config then config args else config;
  configs = map importFile [
    ./auto-pairs.nix
    ./autosave.nix
    ./blankline.nix
    ./bufferline.nix
    ./cmp.nix
    ./fidget.nix
    ./refactoring.nix
    ./git.nix
    ./lightline.nix
    ./lsp.nix
    ./none-ls.nix
    ./nvim-tree.nix
    ./telescope.nix
    ./toggleterm.nix
    ./treesitter.nix
    ./trouble.nix
    ./which_key.nix
    ./wilder.nix
    ./config.nix
  ];
  merged =
    builtins.foldl' (acc: elem: lib.recursiveUpdate acc elem) { } configs;
in {
  home.sessionVariables = { EDITOR = "nvim"; };
  programs.nixvim = merged;
}
