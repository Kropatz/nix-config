{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    xkb.layout = config.mainUser.layout; 
    xkb.variant = config.mainUser.variant;
    displayManager.sddm.enable = true;
    displayManager.sddm.settings.Wayland.SessionDir = "${pkgs.plasma5Packages.plasma-workspace}/share/wayland-sessions";
    #displayManager.sddm.wayland.enable = true;

    libinput = {
      enable = true;

      # disabling mouse acceleration
      mouse = {
        accelProfile = "flat";
      };
    };
  };
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [ ocean-sound-theme spectacle ];

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        #xdg-desktop-portal-gtk
      ];
    };
  };


  environment.systemPackages = with pkgs; [
    wayland-utils
  ];
}
