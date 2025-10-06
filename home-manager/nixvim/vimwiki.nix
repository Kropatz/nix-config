{
  plugins.vimwiki = {
    enable = true;
    settings = {
      list = [
        {
          ext = ".md";
          path = "/synced/default/vimwiki/";
          syntax = "markdown";
        }
      ];
    };
  };
}
