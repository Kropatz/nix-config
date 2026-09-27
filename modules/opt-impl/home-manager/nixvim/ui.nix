{ config, ... }:
{

  opts = {
    timeoutlen = 500;
  };
  plugins = {
    which-key.enable = true;
    barbar.enable = true; # tab bar up top
    trouble.enable = true; # display errors and warnings
    indent-blankline = {
      enable = true;
      settings = {
        indent = {
          smart_indent_cap = true;
          char = " ";
        };
        scope = {
          enabled = true;
          char = "│";
        };
      };
    };
    lightline.enable = true; # status line at the bottom
    colorizer = {
      enable = true; # highlight colors in text
      # no auto-attach, extraConfigLua below attaches only to buffers under a size limit
      settings.filetypes.__raw = "{}"; # a plain [ ] gets dropped by nixvim
    };
    # wilder = {
    #   enable = true;
    #   modes = [
    #     ":"
    #     "/"
    #     "?"
    #   ];
    #   options = {
    #     renderer = config.lib.nixvim.mkRaw ''
    #       wilder.popupmenu_renderer(
    #         wilder.popupmenu_border_theme({
    #           highlights = { border = 'Normal' },
    #           border = 'rounded',
    #           pumblend = 20,
    #         })
    #       )
    #     '';
    #   };
    # }; # better command line and search
    fidget = {
      enable = true;
      settings.progress = {
        suppress_on_insert = true;
        ignore_done_already = true;
        poll_rate = 1;
      };
    }; # show LSP progress in the corner
  };
  # colorizer hangs on huge (minified) lines, only attach to buffers under a size limit
  extraConfigLua = ''
    local colorizer_max_bytes = 1024 * 1024
    local function buf_bytes(buf)
      return vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
    end
    local colorizer_guard = vim.api.nvim_create_augroup("colorizer_size_guard", { clear = true })
    vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
      group = colorizer_guard,
      callback = function(args)
        local c = require("colorizer")
        if vim.bo[args.buf].buftype == "" and buf_bytes(args.buf) <= colorizer_max_bytes
          and not c.is_buffer_attached(args.buf) then
          c.attach_to_buffer(args.buf)
        end
      end,
    })
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
      group = colorizer_guard,
      callback = function(args)
        local c = require("colorizer")
        if c.is_buffer_attached(args.buf) and buf_bytes(args.buf) > colorizer_max_bytes then
          c.detach_from_buffer(args.buf)
        end
      end,
    })
  '';
}
