{ config, pkgs, lib, ... }:

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

  home-manager.users.kopatz = {
    #systemd.user.services.waybar.Service.ExecStart = lib.mkForce "${pkgs.waybar}/bin/waybar -b 0";
    programs.waybar = {
      enable = true;
      #systemd.enable = true;
      #systemd.target = "sway-session.target";
      settings.main = {
	layer = "bottom";
	position = "bottom";
	#output = lib.mapAttrsToList (n: v: v.monitor) outputs;
	height = 25;
	spacing = 4;
	modules-left = [
	  "hyprland/workspaces"
	];
	modules-center = [];
	modules-right = [
	  "network"
	    "cpu"
	    "memory"
	    "temperature"
	    "backlight"
	    "pulseaudio"
	    "battery"
	    "clock"
	    "tray"
	];
	"network".format-wifi = "{essid} ({signalStrength}%) ";
	"network".format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
	"network".format-disconnected = "Disconnected ⚠";
	"network".interval = 7;
	"cpu".format = "CPU: {usage}% ";
	"memory".format = "MEM: {}% ";
	"temperature".critical-threshold = 80;
	"temperature".format = "{temperatureC}°C ";
	"backlight".format = "{percent}% {icon}";
	"backlight".states = [0 50];
	"backlight".format-icons = ["" ""];
	"pulseaudio".format = "{volume}% {icon}";
	"pulseaudio".format-bluetooth = ": {volume}% {icon}";
	"pulseaudio".format-muted = "";
	"pulseaudio".format-icons.headphones = "";
	"pulseaudio".format-icons.handsfree = "";
	"pulseaudio".format-icons.headset = "";
	"pulseaudio".format-icons.phone = "";
	"pulseaudio".format-icons.portable = "";
	"pulseaudio".format-icons.car = "";
	"pulseaudio".format-icons.default = ["" ""];
	"pulseaudio".on-click = "pavucontrol";
	"battery".states.good = 95;
	"battery".states.warning = 30;
	"battery".states.critical = 15;
	"battery".format = "{capacity}% {icon}";
	"battery".format-icons = ["" "" "" "" ""];
	"clock".format = "{:%F %H:%M}";
	"tray".icon-size = 21;
	"tray".spacing = 10;
	"hyprland/workspaces" = {
          "disable-scroll" = true;
          "all-outputs" = true;
          "active-only" = false;
          "on-click" = "activate";
        };
      };
    };
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
    wayland
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
