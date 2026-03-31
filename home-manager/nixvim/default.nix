{
  lib,
  pkgs,
  osConfig,
  config,
  ...
}:
# https://nix-community.github.io/nixvim/NeovimOptions/index.html
let
  cfg = osConfig.custom.nixvimPlugins;
  args = { inherit lib pkgs config; };

  importFile =
    file:
    let
      config = import file;
    in
    if builtins.isFunction config then config args else config;
  configs = map importFile (
    [
      ./config.nix
    ]
    ++ lib.optionals cfg [
      ./auto-pairs.nix
      ./autosave.nix
      # ./cmp.nix
      ./blink.nix
      ./refactoring.nix
      ./git.nix
      ./lsp.nix
      ./images.nix
      ./none-ls.nix
      ./nvim-tree.nix
      #./neo-tree.nix
      ./telescope.nix
      ./toggleterm.nix
      ./treesitter.nix
      ./trouble.nix
      ./which_key.nix
      ./typst-preview.nix
      ./markdown.nix
      ./hop.nix
      ./surround.nix
      ./vimwiki.nix
      ./ui.nix
      ./experimental.nix
      ./snippets.nix
    ]
  );
  merged = builtins.foldl' (acc: elem: lib.recursiveUpdate acc elem) { } configs;
in
{
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.packages = with pkgs; [
    nixfmt-rfc-style
    plantuml
  ]; # nixd config option to set nixpkgs-fmt should work, but it doesn't
  programs.nixvim = merged;
  xdg.desktopEntries = {
    neovim = {
      name = "Neovim";
      exec = "kitty nvim";
      icon = "nvim";
      type = "Application";
      categories = [
        "Utility"
        "TextEditor"
      ];
      mimeType = [
        "text/markdown"
        "text/plain"
      ];
    };
  };
}
