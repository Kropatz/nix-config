{ config, pkgs, lib, inputs, ... }:

let
  patchedWaybar = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
  });

  #patchedHyprland = pkgs.hyprland.overrideAttrs (oldAttrs: {
  #    version = "0.28.0";
  #});
in
{
  imports = [
    (import ../../home-manager/hyprland-settings.nix ({ user="${config.mainUser.name}"; pkgs = pkgs; layout = config.mainUser.layout; variant = config.mainUser.variant; }))
  ];

  services.xserver = {
    layout = config.mainUser.layout;
    xkbVariant = config.mainUser.variant;
    enable = true;
    displayManager = lib.mkIf (!config.services.xserver.displayManager.gdm.enable) {
      sddm.enable = true;
    };
  };

  environment.sessionVariables = {
    # If your cursor becomes invisible
    #WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS="1";
    #WLR_DRM_NO_ATOMIC="1";
    WLR_DRM_DEVICES = "/dev/dri/card0";
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
}
