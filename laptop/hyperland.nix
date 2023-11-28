{ config, pkgs, lib, inputs, ... }:

let
  patchedWaybar = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
  });
in

{

  services.xserver = {
    layout = "at";
    xkbVariant = "";
    enable = true;
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
    gtk = {
      enable = true;
      theme = { 
        name = "palenight";
        package = pkgs.palenight-theme;
      };
    };
    wayland.windowManager.hyprland = {
      enable = true;
      enableNvidiaPatches = true;
      xwayland.enable = true;
      settings = {
        #
        # Please note not all available settings / options are set here.
        # For a full list, see the wiki
        #
        
        # See https://wiki.hyprland.org/Configuring/Monitors/
        monitor = [ ",preferred,auto,auto" ];
        
        
        
        # See https://wiki.hyprland.org/Configuring/Keywords/ for more
        
        # Execute your favorite apps at launch
        # exec-once = waybar & hyprpaper & firefox
        
        # Source a file (multi-file configs)
        # source = ~/.config/hypr/myColors.conf
        
        # Some default env vars.
        env = "XCURSOR_SIZE,24";
        
        # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
        input = {
            kb_layout = "de";
            kb_variant = "";
            kb_model = "";
            kb_options = "";
            kb_rules = "";
        
            follow_mouse = 1;
        
            touchpad = {
                natural_scroll = true;
            };
        
            sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        };
        
        general = {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
        
            gaps_in = 5;
            gaps_out = 20;
            border_size = 2;
            "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
            "col.inactive_border" = "rgba(595959aa)";
        
            layout = "dwindle";
        };
        
        decoration = {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
        
            rounding = 10;
            #blur = yes
            #blur_size = 3
            #blur_passes = 1
            #blur_new_optimizations = on
        
            drop_shadow = true;
            shadow_range = 4;
            shadow_render_power = 3;
            "col.shadow" = "rgba(1a1a1aee)";
        };
        
        animations = {
            enabled = false;
        
            # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
        
            #bezier = myBezier, 0.05, 0.9, 0.1, 1.05
        
            #animation = windows, 1, 7, myBezier
            #animation = windowsOut, 1, 7, default, popin 80%
            #animation = border, 1, 10, default
            #animation = borderangle, 1, 8, default
            #animation = fade, 1, 7, default
            #animation = workspaces, 1, 6, default
        };
        
        dwindle = {
            # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
            pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = true; # you probably want this
        };
        
        master = {
            # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
            new_is_master = true;
        };
        
        gestures  = {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            workspace_swipe = true;
        };
        
        # Example per-device config
        # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
        #"device:epic-mouse-v1" = {
        #    sensitivity = -0.5;
        #};
        
        # Example windowrule v1
        # windowrule = float, ^(kitty)$
        # Example windowrule v2
        # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        
        
        # See https://wiki.hyprland.org/Configuring/Keywords/ for more
        "$mainMod" = "SUPER";
        
        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        bind = let
	  rofi = "${pkgs.rofi-wayland}/bin/rofi";
	  kitty = "${pkgs.kitty}/bin/kitty";
	  thunar = "${pkgs.xfce.thunar}/bin/thunar";
        in  [ 
	  "$mainMod, Q, exec, ${kitty}"
          "$mainMod, C, killactive"
          "$mainMod, M, exit,"
          "$mainMod, E, exec, ${thunar}"
          "$mainMod, V, togglefloating"
          "$mainMod, S, exec, ${rofi} -show drun -show-icons"
          "ALT, SPACE, exec, ${rofi} -show combi"
          "$mainMod, P, pseudo" # dwindle
          "$mainMod, J, togglesplit" # dwindle
          # Move focus with mainMod + arrow keys
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          
          # Switch workspaces with mainMod + [0-9]
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          
          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"
          
          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          
          "ALT, Tab, cyclenext,"
          "ALT, Tab, bringactivetotop,"
	];

	bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
	];
        
       
	exec-once = [
          "${pkgs.swww}/bin/swww init; sleep 1;"
	  "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator &"
	  "${pkgs.waybar}/bin/waybar &"
	  "${pkgs.dunst}/bin/dunst &"
        ];
      };
    };
    programs.waybar = {
      enable = true;
      #systemd.enable = true;
      #systemd.target = "sway-session.target";
      settings.main = {
	layer = "top";
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
	"pulseaudio".on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
	"battery".states.good = 95;
	"battery".states.warning = 30;
	"battery".states.critical = 15;
	"battery".format = "{capacity}% / {power:.2}W  {icon}";
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
  xdg.portal.extraPortals = lib.mkDefault [ pkgs.xdg-desktop-portal-gtk ];

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
