{ user, pkgs, ... }:
{
  home-manager.users.${user} = {
    gtk = {
      enable = true;
      theme = { 
        name = "palenight";
        package = pkgs.palenight-theme;
      };
      cursorTheme = {
        package = pkgs.libsForQt5.breeze-gtk;
        name = "Breeze-gtk";
      };
    };
  };
}
