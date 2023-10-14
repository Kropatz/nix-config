{ config, pkgs, ... }:

let
  patchedWaybar = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
  });
in

{
  imports =
    [ # Include the results of the hardware scan.
	./main.nix
    ];

  services.xserver = {
    layout = "at";
    xkbVariant = "";
    enable = true;
    displayManager.sddm.enable = true;
  };

  programs.hyprland = {
    enable = true;
    nvidiaPatches = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    # If your cursor becomes invisible
    #WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    WLR_DRM_DEVICES = "/dev/dri/card0";
  };

  hardware = {
      # Opengl
      opengl.enable = true;

      # Most wayland compositors need this
      nvidia.modesetting.enable = true;
  };

  # XDG portal
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # hyprland stuff
    patchedWaybar
    dunst
    swww
    kitty
    rofi-wayland
    libnotify
    networkmanagerapplet
  ];
}
