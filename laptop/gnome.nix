{ config, pkgs, ... }:

{

  imports =
  [
        ./main.nix
  ];

  services.xserver = {
    layout = "at";
    xkbVariant = "";
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.gnome.excludePackages = (with pkgs; [
  gnome-photos
  gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    gnome-terminal
    gedit # text editor
    epiphany # web browser
    #geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  environment.systemPackages = with pkgs; [
    wmctrl
    gnome.mutter
    gnome.adwaita-icon-theme
    gnome.gnome-settings-daemon
    gnome.gnome-tweaks
    gnome.dconf-editor
    gruvbox-gtk-theme
    colloid-icon-theme
    gnomeExtensions.appindicator
    gnomeExtensions.just-perfection
    gnomeExtensions.system-monitor
    gnomeExtensions.dash2dock-lite
    gnomeExtensions.dash-to-dock
    gnomeExtensions.vitals
    gnomeExtensions.rounded-window-corners
    gnomeExtensions.wallpaper-switcher
    gnomeExtensions.backslide
    gnomeExtensions.nextcloud-folder
    rofi
  ];
}
