{
  plugins = {
    hop = {
      enable = true;
    };
    auto-save = {
      enable = true;
      settings.enabled = true;
    };
    nvim-autopairs = {
      enable = true;
    };
    grug-far = {
      enable = true;
      lazyLoad.settings.cmd = "GrugFar";
      # keybinds moved to config.nix, my merging method sux and having multiple lists overrides the other
    };
    refactoring = {
      enable = true;
      lazyLoad.settings = {
        cmd = "Refactor";
      };
    };
    nvim-surround.enable = true;
  };
}
