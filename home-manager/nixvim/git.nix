{
  plugins = {
    diffview = { enable = true; };
    neogit = {
      enable = true;
      settings.integrations = { diffview = true; };
    };
    gitsigns = {
      enable = true;
      settings = {
        current_line_blame = true;
        trouble = true;
      };
    };
  };
}
