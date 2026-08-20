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
        owner = "chrisgrieser";
        repo = "nvim-rip-substitute";
        "rev" = "e3e1696bf934af7ae9130daabcafa07d9176d195";
        "hash" = "sha256-ypfQAGgFAuqyNtKtMMMZsZpE1/5OUNilYkimZPpDSOM=";
      };
    })
  ];
}
