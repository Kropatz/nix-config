{ pkgs, config, ...}: {
  home.file.".config/i3" = {
    enable = true;
    recursive = true;
    source = ../.config/i3;
    target = ".config/i3";
  };

  home.file.".config/picom" = {
    enable = true;
    recursive = true;
    source = ../.config/picom;
    target = ".config/picom";
  };

  home.file.".config/wallpapers" = {
    enable = true;
    recursive = true;
    source = ../.config/wallpapers;
    target = ".config/wallpapers";
  };
}
