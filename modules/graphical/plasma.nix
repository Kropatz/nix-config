{ lib, config, pkgs, ... }:
with lib;
let cfg = config.custom.graphical.plasma;
in {
  options.custom.graphical.plasma = {
    enable = mkEnableOption "Enables plasma";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      xkb.layout = config.mainUser.layout;
      xkb.variant = config.mainUser.variant;
      displayManager = {
        sddm.enable = true;
      };
      #displayManager.sddm.settings.Wayland.SessionDir = "${pkgs.plasma5Packages.plasma-workspace}/share/wayland-sessions";
      #displayManager.sddm.wayland.enable = true;

    };
    services.xserver.desktopManager.plasma5.enable = true;

    #services.desktopManager.plasma6.enable = true;
    #environment.plasma6.excludePackages = with pkgs.kdePackages; [ ocean-sound-theme spectacle ];

    #environment.sessionVariables = {
    #  __GL_YIELD = "usleep";
    #  MOZ_ENABLE_WAYLAND = "1";
    #  NIXOS_OZONE_WL = "1";
    #};

    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs;
          [
            xdg-desktop-portal-wlr
            #xdg-desktop-portal-gtk
          ];
      };
    };

    environment.systemPackages = with pkgs; [
      libsForQt5.bismuth # auto tiling
      wayland-utils
    ];
  };
}
