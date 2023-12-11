{ config, pkgs, lib, inputs, vars, ... }:

let
  patchedWaybar = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
  });

  #patchedHyprland = pkgs.hyprland.overrideAttrs (oldAttrs: {
  #    version = "0.28.0";
  #});
in
{

  services.xserver = {
    layout = vars.layout;
    xkbVariant = vars.variant;
    enable = true;
    displayManager = lib.mkIf  (!config.services.xserver.displayManager.gdm.enable) {
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

  home-manager.users.kopatz = {
    #systemd.user.services.waybar.Service.ExecStart = lib.mkForce "${pkgs.waybar}/bin/waybar -b 0";

    programs.swaylock.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      enableNvidiaPatches = true;
      xwayland.enable = true;
      package = pkgs.unstable.hyprland;
      settings = {
        #
        # Please note not all available settings / options are set here.
        # For a full list, see the wiki
        #
        
        # See https://wiki.hyprland.org/Configuring/Monitors/
        monitor = [ 
          "HDMI-A-1,1920x1080@60,0x0,1"
          "DP-1,2560x1440@144,1920x0,1"
          ",preferred,auto,auto" 
        ];
        
        # See https://wiki.hyprland.org/Configuring/Keywords/ for more
        
        # Execute your favorite apps at launch
        # exec-once = waybar & hyprpaper & firefox
        
        # Source a file (multi-file configs)
        # source = ~/.config/hypr/myColors.conf
        
        # Some default env vars.
        env = "XCURSOR_SIZE,24";
        
        # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
        input = {
            kb_layout = vars.layout;
            kb_variant = vars.variant;
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
            # See https://wiki.hyprland.org/Configuring/Variables
        
            gaps_in = 5;
            gaps_out = 5;
            border_size = 2;
            "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
            "col.inactive_border" = "rgba(595959aa)";
        
            layout = "dwindle";
            #allow_tearing = true;
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
            enabled = true;
        
            # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
        
            #bezier = myBezier, 0.05, 0.9, 0.1, 1.05
        
            #animation = windows, 1, 7, myBezier
            #animation = windowsOut, 1, 7, default, popin 80%
            #animation = border, 1, 10, default
            #animation = borderangle, 1, 8, default
            #animation = fade, 1, 7, default
            animation = [
              "workspaces, 0"
            ];
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
        # float,class:^(kitty)$,title:^(kitty)$
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        
        
        # See https://wiki.hyprland.org/Configuring/Keywords/ for more
        "$mainMod" = "SUPER";
        
        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        bind = let
	  rofi = "${pkgs.rofi-wayland}/bin/rofi";
	  konsole = "${pkgs.konsole}/bin/konsole";
	  thunar = "${pkgs.xfce.thunar}/bin/thunar";
	  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
	  wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
	  grim = "${pkgs.grim}/bin/grim";
	  slurp = "${pkgs.slurp}/bin/slurp";
          swww = "${pkgs.swww}/bin/swww";
          pdfgrep = "${pkgs.pdfgrep}/bin/pdfgrep";
          brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
          swaylock = "${pkgs.swaylock}/bin/swaylock";
        in  [ 
	  "$mainMod, Q, exec, ${konsole}"
          "$mainMod, C, killactive"
          "$mainMod, L, exec, ${swaylock} -f -c 000000"
          "$mainMod, M, exit,"
          "$mainMod, E, exec, ${thunar}"
          "$mainMod, V, togglefloating"
          "$mainMod, I, exec, ${rofi} -show drun -show-icons"
          "$mainMod, S, exec, cat ~/songs | shuf -n 0 | sed \"s/^/b\.p /g\" | ${wl-copy}"
          "$mainMod, R, exec, ${swww} img $(ls -d ~/Nextcloud/dinge/Bg/* | shuf -n 1)"
          "        , Print, exec, ${grim} -g \"$(${slurp} -d)\" - | ${wl-copy}"
          "ALT, SPACE, exec, ${rofi} -show combi"
          " , XF86MonBrightnessUp, exec, ${brightnessctl} s +5%"
          " , XF86MonBrightnessDown, exec, ${brightnessctl} s 5%-"
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

        windowrulev2 = [
          # -- Fix odd behaviors in IntelliJ IDEs --
          #! Fix focus issues when dialogs are opened or closed
          "windowdance,class:^(jetbrains-.*)$,floating:1"
          #! Fix splash screen showing in weird places and prevent annoying focus takeovers
          "center,class:^(jetbrains-.*)$,title:^(splash)$,floating:1"
          "nofocus,class:^(jetbrains-.*)$,title:^(splash)$,floating:1"
          "noborder,class:^(jetbrains-.*)$,title:^(splash)$,floating:1"
          
          #! Center popups/find windows
          "center,class:^(jetbrains-.*)$,title:^( )$,floating:1"
          "stayfocused,class:^(jetbrains-.*)$,title:^( )$,floating:1"
          "noborder,class:^(jetbrains-.*)$,title:^( )$,floating:1"
          #! Disable window flicker when autocomplete or tooltips appear
          "nofocus,class:^(jetbrains-.*)$,title:^(win.*)$,floating:1"
          #"immediate, class:^(Risk.*)$"
        ];
        
       
	exec-once = [
          "${pkgs.swww}/bin/swww init; sleep 1;"
          "${pkgs.swww} img $(ls -d ~/Nextcloud/dinge/Bg/* | shuf -n 1)"
	  "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator &"
	  "${pkgs.waybar}/bin/waybar &"
	  #"${pkgs.dunst}/bin/dunst &"
        ];
      };
      extraConfig = let
        wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
        wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
        dunstify = "${pkgs.dunst}/bin/dunstify";
        dunstctl = "${pkgs.dunst}/bin/dunstctl";
      in ''
        bind = $mainMod, A, submap, notes

        submap = notes
        # below
        bind = $mainMod, B, exec, ${wl-paste} | grep -B 15 -i -f - ~/Nextcloud/test.txt | sed 's/[ \t]*$//' | ${wl-copy}
        # above
        bind = $mainMod, A, exec, ${wl-paste} | grep -A 15 -i -f - ~/Nextcloud/test.txt | sed 's/[ \t]*$//' | ${wl-copy}
        # context
        bind = $mainMod, C, exec, ${wl-paste} | grep -C 15 -i -f - ~/Nextcloud/test.txt | sed 's/[ \t]*$//' | ${wl-copy}
        # trim
        bind = $mainMod, T, exec, ${wl-paste} | sed 's/[ \t]*$//' | sed 's/^[ \t]*//' | ${wl-copy}
        bind = $mainMod, N, exec, ${dunstify} "$(${wl-paste})"
        bind = $mainMod, D, exec, ${dunstctl} close-all
        # notes
        bind = $mainMod, 1, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
        bind = $mainMod, 2, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
        bind = $mainMod, 3, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
        bind = $mainMod, 4, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
        bind = $mainMod, 5, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
        bind = $mainMod, 6, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
        bind = $mainMod, 7, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
        bind = $mainMod, 8, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
        bind = $mainMod, 0, exec, cat ~/Nextcloud/test.txt | ${wl-copy}

        bind = , escape, submap, reset
        submap = reset
      '';
    };
    services.dunst = {
      enable = true;
      settings = {
        global = {
           width = "(0,1000)";
           height = "1000";
           offset = "0x0";
           origin = "bottom-center";
           transparency = -1;
           frame_color = "#1a1c1b";
           font = "Monospace 8";
        };

         urgency_normal = {
          background = "#1a1c1b";
          foreground = "#eceff1";
          timeout = 10;
        };
      };
    };
    programs.waybar = {
      enable = true;
      #systemd.enable = true;
      #systemd.target = "sway-session.target";
      settings.main = {
	layer = "top";
	position = "top";
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
      style = ''
        * {
          font-family: FiraCode , Noto Sans,FontAwesome, Roboto, Helvetica, Arial, sans-serif;
          font-size: 13px;
        }
        
        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #network,
        #pulseaudio,
        #custom-media,
        #tray,
        #mode,
        #idle_inhibitor,
        #custom-expand,
        #custom-cycle_wall,
        #custom-ss,
        #custom-dynamic_pill,
        #mpd {
            padding: 0 10px;
            border-radius: 15px;
            background: #11111b;
            color: #b4befe;
            box-shadow: rgba(0, 0, 0, 0.116) 2 2 5 2px;
            margin-top: 10px;
            margin-bottom: 10px;
            margin-right: 10px;
        }
        
        window#waybar {
            background-color: transparent;
        }
        
        #custom-dynamic_pill label {
            color: #11111b;
            font-weight: bold;
        }
        
        #custom-dynamic_pill.paused label {
            color: 	#89b4fa ;
            font-weight: bolder; 
        }
        
        #workspaces button label{
            color: 	#89b4fa ;
            font-weight: bolder;
        }
        
        #workspaces button.active label{
            color: #11111b;
            font-weight: bolder;
        }
        
        #workspaces{
            background-color: transparent;
            margin-top: 10px;
            margin-bottom: 10px;
            margin-right: 10px;
            margin-left: 25px;
        }
        #workspaces button{
            box-shadow: rgba(0, 0, 0, 0.116) 2 2 5 2px;
            background-color: #11111b ;
            border-radius: 15px;
            margin-right: 10px;
            padding: 10px;
            padding-top: 4px;
            padding-bottom: 2px;
            font-weight: bolder;
            color: 	#89b4fa ;
            transition: all 0.5s cubic-bezier(.55,-0.68,.48,1.68);
        }
        
        #workspaces button.active{
            padding-right: 20px;
            box-shadow: rgba(0, 0, 0, 0.288) 2 2 5 2px;
            padding-left: 20px;
            padding-bottom: 3px;
            background: rgb(203,166,247);
            background: radial-gradient(circle, rgba(203,166,247,1) 0%, rgba(193,168,247,1) 12%, rgba(249,226,175,1) 19%, rgba(189,169,247,1) 20%, rgba(182,171,247,1) 24%, rgba(198,255,194,1) 36%, rgba(177,172,247,1) 37%, rgba(170,173,248,1) 48%, rgba(255,255,255,1) 52%, rgba(166,174,248,1) 52%, rgba(160,175,248,1) 59%, rgba(148,226,213,1) 66%, rgba(155,176,248,1) 67%, rgba(152,177,248,1) 68%, rgba(205,214,244,1) 77%, rgba(148,178,249,1) 78%, rgba(144,179,250,1) 82%, rgba(180,190,254,1) 83%, rgba(141,179,250,1) 90%, rgba(137,180,250,1) 100%); 
            background-size: 400% 400%;
            animation: gradient_f 20s ease-in-out infinite;
            transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
        }
        
        @keyframes gradient {
        	0% {
        		background-position: 0% 50%;
        	}
        	50% {
        		background-position: 100% 30%;
        	}
        	100% {
        		background-position: 0% 50%;
        	}
        }
        
        @keyframes gradient_f {
        	0% {
        		background-position: 0% 200%;
        	}
            50% {
                background-position: 200% 0%;
            }
        	100% {
        		background-position: 400% 200%;
        	}
        }
        
        @keyframes gradient_f_nh {
        	0% {
        		background-position: 0% 200%;
        	}
        	100% {
        		background-position: 200% 200%;
        	}
        }
        
        
        
        #custom-dynamic_pill.low{
            background: rgb(148,226,213);
            background: linear-gradient(52deg, rgba(148,226,213,1) 0%, rgba(137,220,235,1) 19%, rgba(116,199,236,1) 43%, rgba(137,180,250,1) 56%, rgba(180,190,254,1) 80%, rgba(186,187,241,1) 100%); 
            background-size: 300% 300%;
            text-shadow: 0 0 5px rgba(0, 0, 0, 0.377);
            animation: gradient 15s ease infinite;
            font-weight: bolder;
            color: #fff;
        }
        #custom-dynamic_pill.normal{
            background: rgb(148,226,213);
            background: radial-gradient(circle, rgba(148,226,213,1) 0%, rgba(156,227,191,1) 21%, rgba(249,226,175,1) 34%, rgba(158,227,186,1) 35%, rgba(163,227,169,1) 59%, rgba(148,226,213,1) 74%, rgba(164,227,167,1) 74%, rgba(166,227,161,1) 100%); 
            background-size: 400% 400%;
            animation: gradient_f 4s ease infinite;
            text-shadow: 0 0 5px rgba(0, 0, 0, 0.377);
            font-weight: bolder;
            color: #fff;
        }
        #custom-dynamic_pill.critical{
            background: rgb(235,160,172);
            background: linear-gradient(52deg, rgba(235,160,172,1) 0%, rgba(243,139,168,1) 30%, rgba(231,130,132,1) 48%, rgba(250,179,135,1) 77%, rgba(249,226,175,1) 100%); 
            background-size: 300% 300%;
            animation: gradient 15s cubic-bezier(.55,-0.68,.48,1.68) infinite;
            text-shadow: 0 0 5px rgba(0, 0, 0, 0.377);
            font-weight: bolder;
            color: #fff;
        }
        
        #custom-dynamic_pill.playing{
            background: rgb(137,180,250);
            background: radial-gradient(circle, rgba(137,180,250,120) 0%, rgba(142,179,250,120) 6%, rgba(148,226,213,1) 14%, rgba(147,178,250,1) 14%, rgba(155,176,249,1) 18%, rgba(245,194,231,1) 28%, rgba(158,175,249,1) 28%, rgba(181,170,248,1) 58%, rgba(205,214,244,1) 69%, rgba(186,169,248,1) 69%, rgba(195,167,247,1) 72%, rgba(137,220,235,1) 73%, rgba(198,167,247,1) 78%, rgba(203,166,247,1) 100%); 
            background-size: 400% 400%;
            animation: gradient_f 9s cubic-bezier(.72,.39,.21,1) infinite;
            text-shadow: 0 0 5px rgba(0, 0, 0, 0.377);
            font-weight: bold;
            color: #fff ;
        }
        
        #custom-dynamic_pill.paused{
            background: #11111b ;
            font-weight: bolder;
            color: #b4befe;
        }
        
        #custom-ss{
            background: #11111b;
            color: #89b4fa;
            font-weight:  bolder;
            padding: 5px;
            padding-left: 20px;
            padding-right: 20px;
            border-radius: 15px;
        }
        
        
        #custom-cycle_wall{
            background: rgb(245,194,231);
            background: linear-gradient(45deg, rgba(245,194,231,1) 0%, rgba(203,166,247,1) 0%, rgba(243,139,168,1) 13%, rgba(235,160,172,1) 26%, rgba(250,179,135,1) 34%, rgba(249,226,175,1) 49%, rgba(166,227,161,1) 65%, rgba(148,226,213,1) 77%, rgba(137,220,235,1) 82%, rgba(116,199,236,1) 88%, rgba(137,180,250,1) 95%); 
            color: #fff;
            background-size: 500% 500%;
            animation: gradient 7s linear infinite;
            font-weight:  bolder;
            border-radius: 15px;
        }
        
        #clock label{
            color: #11111b;
            font-weight:  bolder;
        }
        
        /*
        #clock {
            background: rgb(205,214,244);
            background: linear-gradient(118deg, rgba(205,214,244,1) 5%, rgba(243,139,168,1) 5%, rgba(243,139,168,1) 20%, rgba(205,214,244,1) 20%, rgba(205,214,244,1) 40%, rgba(243,139,168,1) 40%, rgba(243,139,168,1) 60%, rgba(205,214,244,1) 60%, rgba(205,214,244,1) 80%, rgba(243,139,168,1) 80%, rgba(243,139,168,1) 95%, rgba(205,214,244,1) 95%); 
        
            background-size: 200% 300%;
        
            animation: gradient_f_nh 4s linear infinite;
            margin-right: 25px;
            color: #fff ;
            text-shadow: 0 0 5px rgba(0, 0, 0, 0.377);
            
            font-size: 15px;
            padding-top: 5px;
            padding-right: 21px;
            font-weight: bolder;
            padding-left: 20px;
        }
        */
        
        #battery.charging, #battery.plugged {
            background-color: #94e2d5 ;
        }
        
        #battery {
            background-color: #11111b;
            color:#a6e3a1;
            font-weight: bolder;
            font-size: 20px;
            padding-left: 15px;
            padding-right: 15px;
        }
        
        @keyframes blink {
            to {
                background-color: #f9e2af;
                color:#96804e;
            }
        }
        
        
        
        #battery.critical:not(.charging) {
            background-color:  #f38ba8;
            color:#bf5673;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }
        
        #cpu label{
            color:#89dceb;
        }
        
        #cpu {
            background: rgb(30,30,46);
            background: radial-gradient(circle, rgba(30,30,46,1) 30%, rgba(17,17,27,1) 100%); 
            color: 	#89b4fa;
        }
        
        #memory {
            background-color: #5f2966;
            color: 	#9a75c7;
            font-weight: bolder;
        }
        
        #disk {
            color: #964B00;
        }
        
        #backlight {
            color: #90b1b1;
        }
        
        #network{
            color:#000;
        }
        
        #network.disabled{
            background-color: #45475a;
        }
        
        #network.disconnected{
            background: rgb(243,139,168);
            background: linear-gradient(45deg, rgba(243,139,168,1) 0%, rgba(250,179,135,1) 100%); 
            color: #fff;
            font-weight: bolder;
            padding-top: 3px;
            padding-right: 11px;
        }
        
        #network.linked, #network.wifi{
            background-color: #a6e3a1 ;
        }
        
        #network.ethernet{
            background-color:#f9e2af ;
        }
        
        #pulseaudio {
            background-color:  	#f57f17;
            color: white;
            font-weight: bolder;
        }
        
        #pulseaudio.muted {
            background-color: #90b1b1;
        }
        
        #custom-media {
            color: #66cc99;
        }
        
        #custom-media.custom-spotify {
            background-color: #66cc99;
        }
        
        #custom-media.custom-vlc {
            background-color: #ffa000;
        }
        
        #temperature {
            background-color: #f9e2af;
            color:#96804e;
        }
        
        #temperature.critical {
            background-color: #f38ba8 ;
            color:#bf5673;
        }
        
        #tray {
            background-color: #2980b9;
        }
        
        #tray > .passive {
            -gtk-icon-effect: dim;
        }
        
        #tray > .needs-attention {
            -gtk-icon-effect: highlight;
            background-color: #eb4d4b;
        }
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
