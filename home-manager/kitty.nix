{ config, pkgs, inputs, ...}:
{
  programs.kitty = {
    enable = true;
    settings = {
      foreground = "#${config.colorScheme.colors.base05}";
      background = "#${config.colorScheme.colors.base00}";
      env = "TERM=xterm-256color";
      # ...
    };
    extraConfig = ''
      map ctrl+left neighboring_window left
      map shift+left move_window right
      map ctrl+down neighboring_window down
      map shift+down move_window up
    '';
  };
}
