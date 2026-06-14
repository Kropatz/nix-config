let
  keymaps = {
    "<leader>sg" = "live_grep";
    "<leader>sf" = {
      action = "find_files";
      options.desc = "[S]earch [F]iles";
    };
    "<leader>gf" = {
      action = "git_files";
      options.desc = "Search [G]it [F]iles";
    };
    "<leader>sb" = {
      action = "current_buffer_fuzzy_find";
      options.desc = "[S]earch [B]uffer";
    };
    "<leader><space>" = {
      action = "buffers";
      options.desc = "List buffers";
    };
    # LSP
    "gd" = {
      action = "lsp_definitions";
      options.desc = "LSP: [G]o to [D]efinition";
    };
    "gI" = {
      action = "lsp_implementations";
      options.desc = "LSP: [G]o to [I]mplementation";
    };
    "gT" = {
      action = "lsp_type_definitions";
      options.desc = "LSP: [G]o to [T]ype definition";
    };
    "gr" = {
      action = "lsp_references";
      options.desc = "LSP: [G]o to [R]eferences";
    };
    "<leader>ds" = {
      action = "lsp_document_symbols";
      options.desc = "LSP: [D]ocument [S]ymbols";
    };
    "<leader>ws" = {
      action = "lsp_workspace_symbols";
      options.desc = "LSP: [W]orkspace [S]ymbols";
    };
    # end LSP
    # start git
    "<leader>gc" = {
      action = "git_bcommits";
      options.desc = "[G]it: Buffer [C]ommits";
    };
    "<leader>gb" = {
      action = "git_branches";
      options.desc = "[G]it: [B]ranches";
    };
    # end git
  };
in
{
  plugins.telescope = {
    enable = true;
    inherit keymaps;
    lazyLoad.settings.keys = builtins.attrNames keymaps;
    extensions = {
      # doesnt show up ? idk
      #ui-select = {
      #  enable = true;
      #};
      fzf-native.enable = true;
    };
  };
}
