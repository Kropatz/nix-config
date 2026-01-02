let 
    keymaps = {
      "<leader>sg" = "live_grep";
      "<leader>sf" = {
        action = "find_files";
        options.desc = "[S]earch [F]iles";
      };
      "<leader>gf" = {
        action = "git_files";
        options.desc = "Search [G]it [F]iles";
      };
      "<leader><space>" = {
        action = "buffers";
        options.desc = "List buffers";
      };
    };
  in
{
  plugins.telescope = {
    enable = true;
    inherit keymaps;
    lazyLoad.settings.keys = builtins.attrNames keymaps;
    extensions = {
      # doesnt show up ? idk
      #ui-select = {
      #  enable = true;
      #};
      fzf-native.enable = true;
    };
  };
}
