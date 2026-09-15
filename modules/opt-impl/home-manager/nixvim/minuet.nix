{ config, ... }:
let
  inherit (config.lib.nixvim) mkRaw;
in
{
  plugins.minuet = {
    enable = true;
    settings = {
      provider = "openai_fim_compatible";
      n_completions = 1;
      context_window = 4096;
      request_timeout = 10;
      throttle = 1000;
      debounce = 400;
      notify = "warn";
      before_cursor_filter_length = 2;
      after_cursor_filter_length = 2;
      virtualtext = {
        auto_trigger_ft = [ "*" ];
        keymap = {
          accept = "<M-l>";
          accept_line = "<M-j>";
          next = "<M-]>";
          prev = "<M-[>";
          dismiss = "<M-e>";
        };
      };
      provider_options.openai_fim_compatible = {
        api_key = mkRaw ''
          function()
            return "local"
          end
        '';
        name = "zeta-2.1";
        end_point = "http://localhost:4442/v1/completions";
        model = "zeta-2.1";
        stream = false;
        optional = {
          max_tokens = 128;
          temperature = 0.0;
        };
        template = {
          suffix = false;
          prompt = mkRaw ''
            function(context_before_cursor, context_after_cursor, _)
              local before_rest, current_before = context_before_cursor:match("^(.*\n)([^\n]*)$")
              if not before_rest then
                before_rest, current_before = "", context_before_cursor
              end
              local current_after = context_after_cursor:match("^[^\n]*") or ""
              local after_rest = context_after_cursor:sub(#current_after + 2)
              local filename = vim.api.nvim_buf_get_name(0)
              if filename == "" then
                filename = "[No Name]"
              end
              filename = vim.fn.fnamemodify(filename, ":.")
              return string.format(
                "<[fim-suffix]>%s\n<[fim-prefix]><filename>%s\n%s<|marker_1|>\n%s<|user_cursor|>%s\n<|marker_2|>\n<[fim-middle]>",
                after_rest,
                filename,
                before_rest,
                current_before,
                current_after
              )
            end
          '';
        };
        get_text_fn.no_stream = mkRaw ''
          function(json)
            local text = json.choices and json.choices[1] and json.choices[1].text or ""
            local start = text:find("<|marker_1|>", 1, true)
            local stop = text:find("<|marker_2|>", 1, true)
            if not start or not stop or stop <= start then
              return ""
            end
            text = text:sub(start + #("<|marker_1|>"), stop - 1)
            text = text:gsub("<|user_cursor|>", "")
            text = text:gsub("<|marker_%d+|>", "")
            text = text:gsub("^%s*\n", "")
            if not text:find("%S") then
              return ""
            end
            return text
          end
        '';
      };
    };
  };
}
