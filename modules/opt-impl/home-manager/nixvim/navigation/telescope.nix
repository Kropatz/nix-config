let
  keymaps = {
    # "<leader>sg" = "live_grep";
    "<leader>sg" = "live_grep_args";
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
    "<leader>ff" = {
      action = "treesitter symbols=function";
      options.desc = "[F]ind [F]unctions (treesitter)";
    };
    "<leader><space>" = {
      # action = ''<CMD>lua require("telescope.builtin").buffers({ sort_mru = true, ignore_current_buffer = true })<CR>'';
      # action.__raw = ''require("telescope.builtin").buffers({ sort_mru = true, ignore_current_buffer = true })'';
      options.desc = "List buffers";
      # action = "buffers";
      action = "buffers ignore_current_buffer=true sort_mru=true";
      # settings = {
      #   sort_mru = true;
      #   ignore_current_buffer = true;
      # };
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
    "<leader>gl" = {
      action = "git_commits";
      options.desc = "[G]it: [L]og (all commits)";
    };
    "<leader>gc" = {
      action = "git_bcommits";
      options.desc = "[G]it: Buffer [C]ommits";
    };
    "<leader>gb" = {
      action = "git_branches";
      options.desc = "[G]it: [B]ranches";
    };
    "<leader>gs" = {
      action = "git_status";
      options.desc = "[G]it: [S]tatus (changed files)";
    };
    # end git
  };
  # <CR> opens the commit in diffview instead of checking it out (telescope default)
  openInDiffview = {
    __raw = ''
      function(prompt_bufnr)
        local entry = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        vim.cmd("DiffviewOpen " .. entry.value .. "^!")
      end
    '';
  };
  commitPickerOpts = {
    mappings = {
      i."<CR>" = openInDiffview;
      n."<CR>" = openInDiffview;
    };
  };
in
{
  # Pickaxe: find commits whose diff added/removed lines matching a regex (git log -G)
  keymaps = [
    {
      mode = "n";
      key = "<leader>gS";
      options.desc = "[G]it: [S]earch commit contents (pickaxe)";
      action.__raw = ''
        function()
          vim.ui.input({ prompt = "git log -G " }, function(query)
            if not query or query == "" then return end
            require("lz.n").trigger_load("telescope.nvim")
            require("telescope.builtin").git_commits({
              prompt_title = "Commits touching: " .. query,
              git_command = { "git", "log", "--pretty=oneline", "--abbrev-commit", "-G", query },
            })
          end)
        end
      '';
    }
  ];
  plugins.telescope = {
    enable = true;
    inherit keymaps;
    settings.pickers = {
      git_commits = commitPickerOpts;
      git_bcommits = commitPickerOpts;
    };
    lazyLoad.settings.keys = builtins.attrNames keymaps;
    extensions = {
      # doesnt show up ? idk
      #ui-select = {
      #  enable = true;
      #};
      live-grep-args.enable = true;
      fzf-native.enable = true;
    };
  };
}
