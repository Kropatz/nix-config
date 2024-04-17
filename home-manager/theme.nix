{ config, pkgs, inputs, ...}:
{
  home = {
    pointerCursor = {
      size = 24;
      gtk.enable = true;
      name = "breeze_cursors";
      package = pkgs.libsForQt5.breeze-gtk; # or -icons?
    };
  };
  gtk = {
    enable = true;
    theme = { 
      name = "Tokyonight-Dark-BL";
      package = pkgs.tokyo-night-gtk;
    };
  };
  qt = {
    enable = true;
    platformTheme = "kde";
  };
}
