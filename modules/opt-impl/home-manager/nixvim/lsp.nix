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
  plugins = {
    ts-autotag.enable = true; # auto close and rename html tags
    #plugins.java.enable = true;
    lspconfig.enable = true;
    none-ls = {
      # LSP bridge for diagnostics and formatting
      enable = true;
      sources = {
        diagnostics = {
          golangci_lint.enable = true;
          statix.enable = true;
        };
        formatting = {
          fantomas.enable = true;
          gofmt.enable = true;
          goimports.enable = true;
          #nixfmt.enable = true;
          markdownlint.enable = true;
          shellharden.enable = true;
          shfmt.enable = true;
        };
      };
    };
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
  # otter only attaches to a buffer once it is activated
  autoCmd = [
    {
      event = [ "FileType" ];
      pattern = [ "go" ];
      desc = "Attach otter to embedded languages in go raw strings";
      callback.__raw = ''
        function()
          require("otter").activate()
        end
      '';
    }
  ];

  # treesitter has no injections for go raw strings, so teach it the jetbrains
  # style `// language=<lang>` marker. otter (and highlighting) follow from that.
  extraFiles."after/queries/go/injections.scm".text = ''
    ;; extends

    ; // language=html
    ; const IndexTemplate = `<!DOCTYPE html> ... `
    (
      (comment) @injection.language
      .
      [
        (const_declaration
          (const_spec
            value: (expression_list
              (raw_string_literal
                (raw_string_literal_content) @injection.content))))
        (var_declaration
          (var_spec
            value: (expression_list
              (raw_string_literal
                (raw_string_literal_content) @injection.content))))
        (const_spec
          value: (expression_list
            (raw_string_literal
              (raw_string_literal_content) @injection.content)))
        (var_spec
          value: (expression_list
            (raw_string_literal
              (raw_string_literal_content) @injection.content)))
        (short_var_declaration
          right: (expression_list
            (raw_string_literal
              (raw_string_literal_content) @injection.content)))
        (assignment_statement
          right: (expression_list
            (raw_string_literal
              (raw_string_literal_content) @injection.content)))
      ]
      (#lua-match? @injection.language "^/[/*]%s*language=")
      (#gsub! @injection.language "^/[/*]%s*language=([%w_+-]+).*$" "%1"))

    ; the comment before the first statement of a block is a sibling of the
    ; statement_list instead of the statement, so it needs its own pattern
    (block
      (comment) @injection.language
      .
      (statement_list
        .
        [
          (short_var_declaration
            right: (expression_list
              (raw_string_literal
                (raw_string_literal_content) @injection.content)))
          (assignment_statement
            right: (expression_list
              (raw_string_literal
                (raw_string_literal_content) @injection.content)))
        ])
      (#lua-match? @injection.language "^/[/*]%s*language=")
      (#gsub! @injection.language "^/[/*]%s*language=([%w_+-]+).*$" "%1"))
  '';

  lsp = {
    inlayHints.enable = true;
    servers = {
      # terraform_lsp.enable = true;
      terraformls.enable = true;
      bashls.enable = true;
      #ccls.enable = true;
      clangd.enable = true;
      gopls = {
        enable = true;
        # lspconfig turns gopls' semantic tokens on, and those win over
        # treesitter (125 > 100), which would repaint the injected html/css
        # in raw strings as a plain go string. keep them everywhere but strings.
        config.settings.gopls.semanticTokenTypes.string = false;
      };
      svelte.enable = true;
      #clojure_lsp.enable = true;
      # kubernetes doesnt work ._.
      yamlls = {
        enable = true;
        config.yaml = {
          schemas = {
            "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/refs/heads/master/v1.32.1-standalone-strict/all.json" =
              "/*.k8s.yaml";
          };
        };
      };
      qmlls = {
        enable = true;
        config.cmd = [
          "qmlls"
          "-E"
        ];
      };
      nixd = {
        enable = true;
        config = {
          nixpkgs.expr = "import <nixpkgs> { }";
          formatting.command = [ "nixpkgs-fmt" ];
          options.nixos.expr = ''(builtins.getFlake ("/home/kopatz/projects/github/nix-config")).nixosConfigurations.kop-pc.options'';
        };
      };
      angularls.enable = true;
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
      dartls = {
        enable = true;
        # pub cache packages have a pubspec.yaml but no package_config.json, so
        # analysed as their own project every package: import fails to resolve.
        # keep them in the project's server, which already knows those files.
        config = {
          init_options.onlyAnalyzeProjectsWithOpenFiles = false;
          root_dir.__raw = ''
            function(bufnr, on_dir)
              local path = vim.api.nvim_buf_get_name(bufnr)
              if path:find("/.pub-cache/", 1, true) or vim.startswith(path, "/nix/store/") then
                local client = vim.lsp.get_clients({ name = "dartls" })[1]
                if client then on_dir(client.root_dir) end
                return
              end
              local root = vim.fs.root(bufnr, { "pubspec.yaml" })
              if root then on_dir(root) end
            end
          '';
        };
      };
      pylsp.enable = true;
      lua_ls.enable = true;
      csharp_ls = {
        enable = true;
        package = pkgs.csharp-ls;
      };
      tinymist.enable = true; # typst
      jdtls.enable = true; # TODO: lombok https://nix-community.github.io/nixvim/plugins/lsp/servers/jdtls/index.html?highlight=lombok#pluginslspserversjdtlsenable
    };
    keymaps = [
      # handled in telescope
      # {
      #   key = "gd";
      #   lspBufAction = "definition";
      #   #desc = "LSP: [G]o to [D]efinition";
      # }
      {
        key = "gD";
        lspBufAction = "declaration";
        #desc = "LSP: [G]o to [D]eclaration";
      }
      # handled in telescope
      # {
      #   key = "gT";
      #   lspBufAction = "type_definition";
      #   #desc = "Goto type definition";
      # }
      # {
      #   key = "gr";
      #   lspBufAction = "references";
      #   # desc = "LSP: [G]o to [R]eferences";
      # }
      # {
      #   key = "gI";
      #   lspBufAction = "implementation";
      #   #desc = "LSP: [G]o to [I]mplementation";
      # }
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
      # handled in telescope
      # {
      #   key = "<leader>ds";
      #   lspBufAction = "document_symbol";
      #   #desc = "LSP: [D]ocument [S]ymbols";
      # }
      # {
      #   key = "<leader>ws";
      #   lspBufAction = "workspace_symbol";
      #   #desc = "LSP [W]orkspace [S]ymbols";
      # }
    ];
  };
  diagnostic.settings.virtual_lines.only_current_line = true;
}
