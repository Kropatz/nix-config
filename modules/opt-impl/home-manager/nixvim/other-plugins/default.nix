{ pkgs, ... }:
let
  cursortabSrc = pkgs.fetchFromGitHub {
    owner = "cursortab";
    repo = "cursortab.nvim";
    rev = "53c336bd01afa9160935e4423a424c2adc8160be";
    hash = "sha256-MTRz8vPJ+mo6K4dWNlTtxZcEA+pSHWp4cJs/WQTl1H4=";
  };

  # Requires a stable Go toolchain
  cursortab-server = pkgs.buildGo125Module {
    pname = "cursortab-server";
    version = "0.8.0";
    src = cursortabSrc;
    modRoot = "server";
    vendorHash = "sha256-4S14Vm2Ju084uxB2Zlku4z5AmIZkNZkQpiNgYrcqIbg=";
  };
  cursortab = pkgs.vimUtils.buildVimPlugin {
    pname = "cursortab.nvim";
    version = "0.8.0";
    src = cursortabSrc;
    postInstall = ''
      mkdir -p $out/server
      ln -s ${pkgs.lib.getExe' cursortab-server "cursortab"} $out/server/cursortab
    '';
  };
in
{
  extraPlugins = [
    pkgs.vimPlugins.vim-fetch
    pkgs.vimPlugins.vim-markdown-toc
    # cursortab
  ];

  keymaps = [

    {
      key = "<leader>mt";
      action = "<CMD>GenTocGitLab<CR>";
      options.desc = "Generate markdown table of contents";
    }
  ];
  extraConfigLua = ''
    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function(args)
        vim.keymap.set("n", "gf", function()
          -- read path:line:col while still in the terminal window
          local file = vim.fn.expand("<cfile>")
          if file == "" then return end
          local word = vim.fn.expand("<cWORD>")
          local _, e = word:find(file, 1, true)
          local rest = e and word:sub(e + 1) or ""
          local lnum, col = rest:match("^[:(](%d+)[:,]?(%d*)")

          vim.cmd("wincmd p")       -- go back to previous/main window
          vim.cmd.edit(vim.fn.fnameescape(file))
          if lnum then
            pcall(vim.api.nvim_win_set_cursor, 0,
              { tonumber(lnum), math.max((tonumber(col) or 1) - 1, 0) })
          end
        end, { buffer = args.buf, silent = true })
      end,
    })
    -- require("cursortab").setup({
    --   provider = {
    --     type = "zeta-2.1",
    --     url = "http://localhost:4442",
    --   },
    --   keymaps = {
    --     accept = "<M-l>",
    --     partial_accept = "<M-j>",
    --   },
    -- })
  '';
}
