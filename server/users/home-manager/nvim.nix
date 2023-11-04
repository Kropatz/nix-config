{
  home-manager.users.anon = { pkgs, ...}: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        (nvim-treesitter.withAllGrammars)
      ];
      extraPackages = with pkgs;
        [];
      extraConfig = ''
       set autoindent expandtab tabstop=4 shiftwidth=4
       set clipboard=unnamed
       syntax on
       set cc=80
       colorscheme habamax
       set list
       set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,precedes:«,extends:»
      '';
      coc.enable = true;
      coc.settings = ''
        "suggest.noselect" = true;
        "suggest.enablePreview" = true;
        "suggest.enablePreselect" = false;
        "suggest.disableKind" = true;
        "languageserver": {
            "nix": {
            "command": "${pkgs.nil}/bin/nil",
            "filetypes": ["nix"],
            "rootPatterns":  ["flake.nix"],
            // Uncomment these to tweak settings.
            // "settings": {
            //   "nil": {
            //     "formatting": { "command": ["nixpkgs-fmt"] }
            //   }
            // }
            }
        }
      '';
    };
  };
}
