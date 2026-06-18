{ pkgs, ... }:
{
  #TODO: puts "no information available when doing K (hover)"
  # plugins.noice = {
  #   enable = true;
  #   settings = {
  #     lsp.override = {
  #       "vim.lsp.util.convert_input_to_markdown_lines" = true;
  #       "vim.lsp.util.stylize_markdown" = true;
  #       "cmp.entry.get_documentation" = true;
  #     };
  #   };
  # };
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "rip-substitute";
      src = pkgs.fetchFromGitHub {
        owner = "hrisgrieser";
        repo = "nvim-rip-substitute";
        "rev" = "c65592d88f0fa00396e260da99d9e419f4891e3b";
        "hash" = "sha256-sKfxZxB2b2jUNEc/EvCd81s9FMZqBdiMZXJJKkOUyz4=";
      };
    })
  ];
}
