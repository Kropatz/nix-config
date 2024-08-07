{
  plugins = {
    treesitter = {
      enable = true;
      nixGrammars = true;
      indent = true;

      settings.highlight.enable = true;
    };
    #treesitter-context.enable = true;
    rainbow-delimiters.enable = true;
  };
}
