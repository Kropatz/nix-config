{
  plugins.toggleterm = {
    enable = true;
    settings = {
      open_mapping = "[[<C-t>]]";
    };
    lazyLoad.settings = {
      cmd = "ToggleTerm";
      keys = [
        "<C-t>"
      ];
    };
  };
}
