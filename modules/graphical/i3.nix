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

    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
        config.common.default = "*";
      };
    };

    services = {
      displayManager = { defaultSession = "none+i3"; };

      xserver = {
        enable = true;

        xkb.layout = config.mainUser.layout;
        xkb.variant = config.mainUser.variant;
        desktopManager = { xterm.enable = false; };

        windowManager.i3 = {
          enable = true;
          extraPackages = with pkgs; [
            i3status # gives you the default i3 status bar
            i3lock-color # i3 screen locker
            i3blocks # if you are planning on using i3blocks over i3status
          ];
        };
      };
    };

    security.polkit.enable = true;
    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart =
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      picom # compositor
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
      flameshot
      pmutils # suspend with pm-suspend
      lm_sensors # for cpu in polybar
      feh # sets the wallpaper
      networkmanagerapplet
      caffeine-ng # prevent the system from going to sleep
    ];
  };
}
