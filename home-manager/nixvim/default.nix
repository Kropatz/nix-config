{
  lib,
  pkgs,
  osConfig,
  ...
}:
# https://nix-community.github.io/nixvim/NeovimOptions/index.html
let
  cfg = osConfig.custom.nixvimPlugins;
  args = { inherit lib pkgs; };

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
      ./blankline.nix
      ./barbar.nix
      ./cmp.nix
      ./fidget.nix
      ./refactoring.nix
      ./git.nix
      ./lightline.nix
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
      ./wilder.nix
      ./typst-preview.nix
      ./markdown.nix
      ./hop.nix
      ./colorizer.nix
      ./surround.nix
      ./vimwiki.nix
    ]
  );
  merged = builtins.foldl' (acc: elem: lib.recursiveUpdate acc elem) { } configs;
in
{
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.packages = with pkgs; [ nixfmt-rfc-style ]; # nixd config option to set nixpkgs-fmt should work, but it doesn't
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
