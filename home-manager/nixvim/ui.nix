{ config, ...}:
{
  plugins = {
    barbar = {
      enable = true;
    }; # tab bar up top
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
    lightline = {
      enable = true;
    }; # status line at the bottom
    colorizer.enable = true; # highlight colors in text
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
}
