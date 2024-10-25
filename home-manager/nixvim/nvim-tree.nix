{
  plugins = {
    web-devicons.enable = true;
    nvim-tree = {
      enable = true;
      openOnSetup = true;
      autoReloadOnWrite = true;
      updateFocusedFile.enable = true;
      tab.sync = {
        close = true;
        open = true;
      };
    };
  };
}
