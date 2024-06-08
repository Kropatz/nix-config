{
  plugins.diffview = {
    enable = true;
  };
  plugins.neogit = {
    enable = true;
    integrations = {
      diffview = true;
    };
  };
  plugins.gitsigns = {
    enable = true;
    settings = {
      current_line_blame = true;
      trouble = true;
    };
  };
}
