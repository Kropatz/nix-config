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
      displayManager =
        lib.mkIf (!config.services.xserver.displayManager.gdm.enable) {
          sddm.enable = true;
        };
    };

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      #WLR_DRM_NO_ATOMIC="1";
      #WLR_DRM_DEVICES = "/dev/dri/card0";
      #WLR_RENDERER_ALLOW_SOFTWARE = "1";
    } // lib.mkIf config.custom.hardware.nvidia.enable {
      LIBVA_DRIVER_NAME = "nvidia";
      # black screen :(
      #XDG_SESSION_TYPE = "wayland";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      #WLR_BACKENDS="x11,way
    };

    hardware = {
      # Opengl
      opengl.enable = true;
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = lib.mkDefault [ pkgs.xdg-desktop-portal-gtk ];

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
      #qt5.qtwayland
      #qt6.qmake
      #qt6.qtwayland
      #waybar
      #xdg-desktop-portal-hyprland
      #xdg-desktop-portal-gtk
      #xdg-utils
      #xwayland
    ];
  };
}
