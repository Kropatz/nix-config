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

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      # hyprland stuff
      dunst
      swww
      rofi-wayland
      libnotify
      networkmanagerapplet
      wayland
      wl-clipboard
      cava
      dex # starts applications according to .desktop files
      hyprshade
      #qt5.qtwayland
      #qt6.qmake
      #qt6.qtwayland
      #waybar
      #xdg-utils
      #xwayland
    ];
  };
}
