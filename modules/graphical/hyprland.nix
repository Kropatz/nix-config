{ config, pkgs, lib, inputs, ... }:
with lib;
let
    cfg = config.custom.graphical.hyprland;
in
{
  options.custom.graphical.hyprland = {
      enable = mkEnableOption "Enables hyprland";
  };
  options.custom.graphical.hyprland.videobridge = {
      enable = mkEnableOption "Enables xwaylandvideobridge for hyprland";
  };
  
  config = let
      patchedWaybar = pkgs.unstable.waybar.overrideAttrs (oldAttrs: { mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ]; });
    in mkIf cfg.enable {
      services.xserver = {
        layout = config.mainUser.layout;
        xkbVariant = config.mainUser.variant;
        enable = true;
        displayManager = mkIf (!config.services.xserver.displayManager.gdm.enable) {
          sddm.enable = true;
        };
      };
    
      environment.sessionVariables = {
        # Hint electron apps to use wayland
        NIXOS_OZONE_WL = "1";
        WLR_NO_HARDWARE_CURSORS="1";
        #WLR_DRM_NO_ATOMIC="1";
        #WLR_DRM_DEVICES = "/dev/dri/card0";
        LIBVA_DRIVER_NAME="nvidia";
        # black screen :(
        #XDG_SESSION_TYPE = "wayland";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        WLR_RENDERER_ALLOW_SOFTWARE="1";
      };
    
      hardware = {
          # Opengl
          opengl.enable = true;
    
          # Most wayland compositors need this
          nvidia.modesetting.enable = true;
      };
    
      xdg.portal.enable = true;
      xdg.portal.extraPortals = lib.mkDefault [ pkgs.xdg-desktop-portal-gtk ];
    
      programs.hyprland = {
        enable = true;
        package = pkgs.unstable.hyprland;
      };
    
      security.pam.services = {
        swaylock = {
          fprintAuth = false;
          text = ''
            auth include login
          '';
        };
      };
            
      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        # hyprland stuff
        patchedWaybar
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
