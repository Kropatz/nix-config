{ config, pkgs, lib, ... }:
let cfg = config.custom.graphical.i3;
in {

  options = {
    custom.graphical.i3.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable i3 window manager";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.pathsToLink = [
      "/libexec"
    ]; # links /libexec from derivations to /run/current-system/sw

    services.xserver = {
      enable = true;

      desktopManager = { xterm.enable = false; };

      displayManager = { defaultSession = "none+i3"; };

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          i3status # gives you the default i3 status bar
          i3lock # default i3 screen locker
          i3blocks # if you are planning on using i3blocks over i3status
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      #picom # compositor
      rofi # application
      maim # takes screenshots
      xclip
      dex # starts applications according to .desktop files
      xss-lock # locks the screen when the system is idle
      pavucontrol
      libsForQt5.dolphin
      playerctl
      brightnessctl
      i3blocks
      autotiling
      feh # sets the wallpaper
      nm-tray # NetworkManager tray icon
    ];
  };
}
