{ pkgs, ... }:
{
  # extraConfigLua = ''
  #   --Enable (broadcasting) snippet capability for completion
  #   local capabilities = vim.lsp.protocol.make_client_capabilities()
  #   capabilities.textDocument.completion.completionItem.snippetSupport = true
  #   vim.lsp.config('html', {
  #      capabilities = capabilities,
  #    })
  # '';
  plugins.ts-autotag.enable = true; # auto close and rename html tags
  lsp = {
    inlayHints.enable = true;
    servers = {
      #angularls.enable = true; # Todo: fix
      bashls.enable = true;
      #ccls.enable = true;
      clangd.enable = true;
      gopls.enable = true;
      #clojure_lsp.enable = true;
      qmlls = {
        enable = true;
        settings.cmd = [
          "qmlls"
          "-E"
        ];
      };
      nixd = {
        enable = true;
        settings = {
          nixpkgs.expr = "import <nixpkgs> { }";
          formatting.command = [ "nixpkgs-fmt" ];
          options.nixos.expr = ''(builtins.getFlake ("/home/kopatz/projects/github/nix-config")).nixosConfigurations.kop-pc.options'';
        };
      };
      #angularls.enable = true;
      html = {
        enable = true;
        config = {
          filetypes = [
            "html"
            "htmldjango"
            "razor"
            "htmlangular"
          ];
        };
      };
      cssls.enable = true;
      ts_ls.enable = true;
      dartls.enable = true; # handled by flutter-tools
      pylsp.enable = true;
      lua_ls.enable = true;
      csharp_ls = {
        enable = true;
        package = pkgs.csharp-ls;
      };
      tinymist.enable = true; # typst
    };
    keymaps = [
      {
        key = "gd";
        lspBufAction = "definition";
        #desc = "LSP: [G]o to [D]efinition";
      }
      {
        key = "gD";
        lspBufAction = "declaration";
        #desc = "LSP: [G]o to [D]eclaration";
      }
      {
        key = "gT";
        lspBufAction = "type_definition";
        #desc = "Goto type definition";
      }
      {
        key = "gr";
        lspBufAction = "references";
        # desc = "LSP: [G]o to [R]eferences";
      }
      {
        key = "gI";
        lspBufAction = "implementation";
        #desc = "LSP: [G]o to [I]mplementation";
      }
      {
        key = "K";
        lspBufAction = "hover";
        #desc = "LSP: Show documentation";
      }
      {
        key = "<c-k>";
        lspBufAction = "signature_help";
        #desc = "LSP: Show signature help";
      }
      {
        key = "<leader>rn";
        lspBufAction = "rename";
        #desc = "LSP: [R]e[n]ame";
      }
      {
        key = "<leader>ca";
        lspBufAction = "code_action";
        #desc = "LSP: [C]ode [A]ction";
      }
      {
        key = "<leader>ds";
        lspBufAction = "document_symbol";
        #desc = "LSP: [D]ocument [S]ymbols";
      }
      {
        key = "<leader>ws";
        lspBufAction = "workspace_symbol";
        #desc = "LSP [W]orkspace [S]ymbols";
      }
    ];
  };
  plugins = {
    otter = {
      # provide lsp functionality for code embedded in other languages
      enable = true;
      settings.handle_leading_whitespace = true;
    };

    lsp-lines = {
      enable = true;
    };
    rustaceanvim.enable = true;
  };
  diagnostics.virtual_lines.only_current_line = true;
}
