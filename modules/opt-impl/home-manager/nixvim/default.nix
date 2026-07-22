{
  lib,
  pkgs,
  config,
  ...
}:
# https://nix-community.github.io/nixvim/NeovimOptions/index.html
let
  cfg = config.custom.nixvimPlugins;
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
      ./ui.nix
      ./editing.nix
      # ./cmp.nix
      ./blink.nix
      ./lsp.nix
      ./toggleterm.nix
      ./treesitter.nix
      ./experimental.nix
      ./snippets.nix
      ./support/git.nix
      ./support/images.nix
      ./support/typst-preview.nix
      ./support/vimwiki.nix
      ./support/markdown.nix
      ./navigation/nvim-tree.nix
      ./navigation/telescope.nix
      #./neo-tree.nix
      ./other-plugins
    ]
  );
in
{
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.packages = with pkgs; [
    nixfmt
  ]; # nixd config option to set nixpkgs-fmt should work, but it doesn't
  programs.nixvim = lib.mkMerge configs;
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
