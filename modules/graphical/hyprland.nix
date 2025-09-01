{ config, pkgs, lib, inputs, ... }:
let cfg = config.custom.graphical.hyprland;
in {
  options.custom.graphical.hyprland = {
    enable = lib.mkEnableOption "Enables hyprland";
  };
  options.custom.graphical.hyprland.videobridge = {
    enable = lib.mkEnableOption "Enables xwaylandvideobridge for hyprland";
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      xkb.layout = config.mainUser.layout;
      xkb.variant = config.mainUser.variant;
      enable = true;
    };
    services.displayManager.sddm.enable =
      !config.services.xserver.displayManager.gdm.enable;

    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = lib.mkDefault [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];

    programs.hyprland = { enable = true; };

    security.pam.services.hyprlock = { };
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

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      # hyprland stuff
      dunst
      hyprpaper
      rofi-wayland
      libnotify
      networkmanagerapplet
      wayland
      wl-clipboard
      cava
      dex # starts applications according to .desktop files
      hyprshade
      #waybar
      #qt5.qtwayland
      #qt6.qmake
      #qt6.qtwayland
      #waybar
      #xdg-utils
      #xwayland
      (writeShellScriptBin "copyfiletoclip" ''
          echo "file://$(realpath $1)" | wl-copy -t text/uri-list
        ''
      )

    ];
  };
}
