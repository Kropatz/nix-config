{
  plugins = {
    diffview = {
      enable = true;
      lazyLoad.settings = {
        cmd = "DiffviewOpen";
      };
    };
    lazygit = {
      enable = true;
      lazyLoad.settings = {
        cmd = "LazyGit";
        keys = [
          "<leader>gg"
        ];
      };
    };
    #neogit = {
    #  enable = true;
    #  settings.integrations = { diffview = true; };
    #};
    gitsigns = {
      enable = true;
      settings = {
        current_line_blame = true;
        trouble = true;
      };
    };
  };
}
