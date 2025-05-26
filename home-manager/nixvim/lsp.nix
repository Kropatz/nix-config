{ pkgs, ... }:
{
  plugins = {
    otter = {
      # provide lsp functionality for code embedded in other languages
      enable = true;
      settings.handle_leading_whitespace = true;
    };
    lsp = {
      enable = true;
      inlayHints = true;
      servers = {
        bashls.enable = true;
        #ccls.enable = true; 
        clangd.enable = true;
        cssls.enable = true;
        gopls.enable = true;
        qmlls =
          {
            enable = true;
            cmd = [ "qmlls" "-E" ];
          };
        nixd = {
          enable = true;
          settings = {
            nixpkgs.expr = ''import <nixpkgs> { }'';
            formatting.command = [ "nixpkgs-fmt" ];
            options.nixos.expr = ''(builtins.getFlake ("/home/kopatz/projects/github/nix-config")).nixosConfigurations.kop-pc.options'';
          };
        };
        html.enable = true;
        dartls.enable = true;
        ts_ls.enable = true;
        pylsp.enable = true;
        lua_ls.enable = true;
        csharp_ls = {
          enable = true;
          package = pkgs.csharp-ls;
        };
        #typst-lsp.enable = true;
      };
      keymaps.lspBuf = {
        gd = {
          action = "definition";
          desc = "LSP: [G]o to [D]efinition";
        };
        gD = {
          action = "declaration";
          desc = "LSP: [G]o to [D]eclaration";
        };
        gT = {
          action = "type_definition";
          desc = "Goto type definition";
        };
        gr = {
          action = "references";
          desc = "LSP: [G]o to [R]eferences";
        };
        gI = {
          action = "implementation";
          desc = "LSP: [G]o to [I]mplementation";
        };
        "K" = {
          action = "hover";
          desc = "LSP: Show documentation";
        };
        "<c-k>" = {
          action = "signature_help";
          desc = "LSP: Show signature help";
        };
        "<leader>rn" = {
          action = "rename";
          desc = "LSP: [R]e[n]ame";
        };
        "<leader>ca" = {
          action = "code_action";
          desc = "LSP: [C]ode [A]ction";
        };
        "<leader>ds" = {
          action = "document_symbol";
          desc = "LSP: [D]ocument [S]ymbols";
        };
        "<leader>ws" = {
          action = "workspace_symbol";
          desc = "LSP [W]orkspace [S]ymbols";
        };
      };
    };
    lsp-lines = {
      enable = true;
    };
    rustaceanvim.enable = true;
  };
  diagnostics.virtual_lines.only_current_line = true;
}
