{ config, lib, ... }:
{
  plugins = {
    luasnip.enable = true;
    copilot-lua = {
      enable = true;
      settings = {
        suggestion.enabled = false;
        panel.enabled = false;
      };
    };

    blink-cmp = {
      enable = true;
      settings = {
        appearance = {
          use_nvim_cmp_as_default = true;
        };
        snippets = {
          preset = "luasnip";
        };
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
            "copilot"
          ];
          providers = {
            copilot = {
              name = "copilot";
              module = "blink-cmp-copilot";
            };
            cmdline = {
              min_keyword_length = config.lib.nixvim.mkRaw ''
                function(ctx)
                  -- when typing a command, only show when the keyword is 3 characters or longer
                  if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then return 3 end
                  return 0
                end
              '';
            };
          };
        };

        signature = {
          enabled = true;
        };

        completion = {
          documentation = {
            auto_show = true;
          };
          accept = {
            auto_brackets.enabled = true;
          };
          menu = {
            draw.treesitter = [ "lsp" ];
          };
        };

        cmdline = {
          keymap = {
            preset = "inherit";
            "<CR>" = [ "accept_and_enter" "fallback" ];
          };
          completion = {
            menu = {
              auto_show = true;
            };
          };
        };

        keymap = {
          #preset = "enter";
          preset = "none";
          "<C-n>" = [
            "select_next"
            "fallback"
          ];
          "<C-p>" = [
            "select_prev"
            "fallback"
          ];
          "<C-j>" = [
            "select_next"
            "fallback"
          ];
          "<C-k>" = [
            "select_prev"
            "fallback"
          ];
          "<C-d>" = [
            "scroll_documentation_up"
            "fallback"
          ];
          "<C-f>" = [
            "scroll_documentation_down"
            "fallback"
          ];
          "<C-Space>" = [
            "show"
            "fallback"
          ];
          "<C-e>" = [
            "cancel"
            "fallback"
          ];
          "<CR>" = [
            "accept"
            "fallback"
          ];
          "<Tab>" = [
            "snippet_forward"
            "select_next"
            "fallback"
          ];
          "<S-Tab>" = [
            "snippet_backward"
            "select_prev"
            "fallback"
          ];
        };
      };
    };

    # Extra source packages
    blink-cmp-copilot.enable = true;
  };
}
