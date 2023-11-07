{ user, pkgs, ... }:
{
  home-manager.users.${user} = { pkgs, ...}: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        (nvim-treesitter.withAllGrammars)
        vim-nix
        # Buffer tabs
        {
            plugin = bufferline-nvim;
            type = "lua";
            config = ''
                require("bufferline").setup{ }
                nmap("<leader>b", ":BufferLineCycleNext<cr>")
                nmap("<leader>B", ":BufferLineCyclePrev<cr>")
            '';
        }
        # File browser
        {
            plugin = nvim-tree-lua;
            type = "lua";
            config = ''
                require("nvim-tree").setup()
            '';
        }
      {
        plugin = vim-which-key;
        type = "lua";
        # TODO: How to port this to Lua?
        config = ''
          vim.cmd([[
          map <Space> <Leader>
          let g:mapleader = "\<Space>"
          let g:maplocalleader = ','
          nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
          nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
          ]])
        '';
      }
      ];
      extraPackages = with pkgs; [
        nodejs
        nil
      ];
      extraConfig = ''
      lua << EOF
      ${builtins.readFile ./config.lua}
      EOF
      '';
      coc.enable = true;
      coc.settings = ''
        "suggest.noselect" = true;
        "suggest.enablePreview" = true;
        "suggest.enablePreselect" = false;
        "suggest.disableKind" = true;
        "coc.preferences.formatOnSave" = true;
        "languageserver": {
            "nix": {
            "command": "${pkgs.nil}/bin/nil",
            "filetypes": ["nix"],
            "rootPatterns":  ["flake.nix"],
            }
        }
      '';
    };
  };
}
