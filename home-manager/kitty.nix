{ config, pkgs, inputs, lib, ...}:
{
  programs.kitty = {
    enable = true;
    settings = {
      scrollback_lines = 20000;
      #foreground = "#${config.colorScheme.colors.base05}";
      #background = "#${config.colorScheme.colors.base00}";

      #active_tab_foreground = "#${config.colorScheme.colors.base05}";
      #active_tab_background = "#${config.colorScheme.colors.base01}";
      #inactive_tab_foreground = "#${config.colorScheme.colors.base05}";
      #inactive_tab_background = "#${config.colorScheme.colors.base00}";
      env = "TERM=xterm-256color";
      background_opacity = lib.mkForce "0.85";
      font_size = 13;
      # ...
    };
    extraConfig = ''
      map ctrl+shift+t new_tab_with_cwd
      map ctrl+shift+enter new_window_with_cwd
    '';
  };
}
