return {
  cond = false,
  'huggingface/llm.nvim',
  opts = {
    api_token = "monkey",
    -- cf Setup
    model = "http://localhost:8080/generate",
    query_params = {
      max_new_tokens = 60,
      temperature = 0.2,
      top_p = 0.95,
      stop_token = "<EOT>",
    },
    fim = {
      enabled = true,
      prefix = "<PRE>",
      middle = "<MID>",
      suffix = "<SUF>",
    },
    debounce_ms = 150,
    accept_keymap = "<M-l>",
    dismiss_keymap = "<M-n>",
    max_context_after = 5000,
    max_context_before = 5000,
    tls_skip_verify_insecure = false,
    context_window = 8192, -- max number of tokens for the context window
  }
};
