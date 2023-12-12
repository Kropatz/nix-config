{ user, pkgs, ... }:
{
  home-manager.users.${user} = {
    gtk = {
      enable = true;
      theme = { 
        name = "Tokyonight-Dark-BL";
        package = pkgs.tokyo-night-gtk;
      };
      cursorTheme = {
        package = pkgs.libsForQt5.breeze-gtk;
        name = "Breeze-gtk";
      };
    };
  };
}
