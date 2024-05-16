{ lib, pkgs, ... }:
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
in { programs.nixvim = merged; }
