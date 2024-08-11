{ config, osConfig, pkgs, inputs, lib, ... }:
let cfg = osConfig.custom.graphical.hyprland;
in {
  config = lib.mkIf cfg.enable {
    #programs.swaylock.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      #enableNvidiaPatches = true;
      xwayland.enable = true;
      settings = {
        #
        # Please note not all available settings / options are set here.
        # For a full list, see the wiki
        #

        # See https://wiki.hyprland.org/Configuring/Monitors/
        monitor = if osConfig.networking.hostName == "kop-pc" then [
          # PC
          "HDMI-A-1,1920x1080@60,0x0,1"
          "DP-1,2560x1440@165,1920x0,1"
          "Unknown-1,disable"
        ] else if osConfig.networking.hostName == "nix-laptop" then [
          # laptop
          "eDP-1,1920x1080@60,0x0,1"
          #"DP-3,1920x1080@60,1920x0,1"
          #",preferred,auto,1,mirror,eDP-1" 
          ",preferred,auto,auto"
        ] else
          [
            # Default
            ",preferred,auto,auto"
          ];

        workspace =
          lib.lists.optionals (osConfig.networking.hostName == "kop-pc") [
            "1,monitor:DP-1"
            "2,monitor:DP-1"
            "3,monitor:DP-1"
            "4,monitor:DP-1"
            "5,monitor:DP-1"
            "9,monitor:HDMI-A-1"
            "10,monitor:HDMI-A-1"
          ];

        # See https://wiki.hyprland.org/Configuring/Keywords/ for more

        # Execute your favorite apps at launch
        # exec-once = waybar & hyprpaper & firefox

        # Source a file (multi-file configs)
        # source = ~/.config/hypr/myColors.conf

        # Some default env vars.
        env =
          [ "XCURSOR_SIZE,24" "NIXOS_OZONE_WL,1" "WLR_NO_HARDWARE_CURSORS,1" ]
          // lib.optional osConfig.custom.hardware.nvidia.enable [
            "LIBVA_DRIVER_NAME,nvidia"
            "GBM_BACKEND,nvidia-drm"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          ];

        # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
        input = {
          kb_layout = osConfig.mainUser.layout;
          kb_variant = osConfig.mainUser.variant;
          kb_model = "";
          kb_options = "";
          kb_rules = "";

          follow_mouse = 1;
          float_switch_override_focus = 2;

          touchpad = { natural_scroll = true; };

          sensitivity = if osConfig.networking.hostName == "kop-pc" then
            -0.4
          else
            0; # -1.0 - 1.0, 0 means no modification.
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

        misc = { vfr = true; };

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
          animation = [ "workspaces, 0" ];
        };

        dwindle = {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile =
            true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true; # you probably want this
        };

        master = {
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          #new_is_master = true;
          new_status = "master";
        };

        gestures = {
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
          kitty = "${pkgs.kitty}/bin/kitty";
          #dolphin = "${pkgs.dolphin}/bin/dolphin";
          thunar = "${pkgs.xfce.thunar}/bin/thunar";
          wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
          wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
          grim = "${pkgs.grim}/bin/grim";
          slurp = "${pkgs.slurp}/bin/slurp";
          swww = "${pkgs.swww}/bin/swww";
          pdfgrep = "${pkgs.pdfgrep}/bin/pdfgrep";
          brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
          #swaylock = "${pkgs.swaylock}/bin/swaylock";
          hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
          playerctl = "${pkgs.playerctl}/bin/playerctl";
        in [
          "$mainMod, Q, exec, ${kitty}"
          "$mainMod, C, killactive"
          #"$mainMod, L, exec, ${swaylock} -f -c 000000"
          "$mainMod, L, exec, ${hyprlock}"
          "$mainMod, M, exit,"
          "$mainMod, E, exec, ${thunar}"
          "$mainMod, F, fullscreen"
          "$mainMod, V, togglefloating"
          "$mainMod, I, exec, ${rofi} -show drun -show-icons"
          ''
            $mainMod, S, exec, cat ~/songs | shuf -n 1 | sed "s/^/b.p /g" | ${wl-copy}''
          "$mainMod, R, exec, ${swww} img $(ls -d /synced/default/dinge/Bg/* | shuf -n 1)"
          "        , Print, exec, ${grim} -g \"$(${slurp} -d)\" - | ${wl-copy}"
          ''
            $mainMod, Print, exec, ${grim} -g "$(${slurp} -d)" /tmp/$(date +'%s_grim.png')''
          ''
            Shift_L, Print, exec, ${grim} -g "$(${slurp} -d)" ~/Pictures/$(date +'%s_grim.png')''
          "$mainMod, SPACE, exec, ${rofi} -modi drun -show drun -config ~/.config/rofi/rofidmenu.rasi"
          " , XF86MonBrightnessUp, exec, ${brightnessctl} s +5%"
          " , XF86MonBrightnessDown, exec, ${brightnessctl} s 5%-"
          " , XF86AudioPlay, exec, ${playerctl} play-pause"
          " , XF86AudioNext, exec, ${playerctl} next"
          " , XF86AudioPrev, exec, ${playerctl} previous"
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

          # "ALT, Tab, cyclenext,"
          # "ALT, Tab, bringactivetotop,"
        ];

        bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        windowrulev2 = [

          #"center, class:jetbrains-idea"
          #"noinitialfocus,class:^jetbrains-(?!toolbox),floating:1"

          ## -- Fix odd behaviors in IntelliJ IDEs --
          ##! Fix focus issues when dialogs are opened or closed
          #"windowdance,class:^(jetbrains-.*)$,floating:1"
          ##! Fix splash screen showing in weird places and prevent annoying focus takeovers
          #"center,class:^(jetbrains-.*)$,title:^(splash)$,floating:1"
          #"nofocus,class:^(jetbrains-.*)$,title:^(splash)$,floating:1"
          #"noborder,class:^(jetbrains-.*)$,title:^(splash)$,floating:1"

          ##! Center popups/find windows
          #"center,class:^(jetbrains-.*)$,title:^( )$,floating:1"
          #"stayfocused,class:^(jetbrains-.*)$,title:^( )$,floating:1"
          #"noborder,class:^(jetbrains-.*)$,title:^( )$,floating:1"
          ##! Disable window flicker when autocomplete or tooltips appear
          #"nofocus,class:^(jetbrains-.*)$,title:^(win.*)$,floating:1"
          ##"immediate, class:^(Risk.*)$"
        ];

        exec-once = [
          "${pkgs.swww}/bin/swww init; sleep 1;"
          "${pkgs.swww} img $(ls -d /synced/default/dinge/Bg/* | shuf -n 1)"
          "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator &"
          "${pkgs.waybar}/bin/waybar &"
          "dex --autostart --environment Hyprland"
          "hypridle &"
          #"${pkgs.dunst}/bin/dunst &"
        ] ++ lib.lists.optionals (osConfig.networking.hostName == "kop-pc") [
          "[workspace 9 silent] vesktop"
          "[workspace 10 silent] firefox"
        ];
      };
      extraConfig = let
        wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
        wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
        dunstify = "${pkgs.dunst}/bin/dunstify";
        dunstctl = "${pkgs.dunst}/bin/dunstctl";
        pdfgrep = "${pkgs.pdfgrep}/bin/pdfgrep --cache";
        path = "/synced/fh/os-hardening/**/slides";
      in ''
        bind = $mainMod, A, submap, notes

        submap = notes
        # below
        bind = $mainMod, B, exec, ${wl-paste} | xargs -I {} ${pdfgrep} -B 15 -h -i "{}" ${path}/*.pdf | sed 's/[ \t]*$//' | ${wl-copy}
        # above
        bind = $mainMod, A, exec, ${wl-paste} | xargs -I {} ${pdfgrep} -A 15 -h -i "{}" ${path}/*.pdf | sed 's/[ \t]*$//' | ${wl-copy}
        # context
        bind = $mainMod, C, exec, ${wl-paste} | xargs -I {} ${pdfgrep} -C 15 -h -i "{}" ${path}/*.pdf | sed 's/[ \t]*$//' | ${wl-copy}
        # trim
        bind = $mainMod, T, exec, ${wl-paste} | sed 's/[ \t]*$//' | sed 's/^[ \t]*//' | sed '/^[[:space:]]*$/d' | ${wl-copy}
        bind = $mainMod, N, exec, ${dunstify} "$(${wl-paste})"
        bind = $mainMod, D, exec, ${dunstctl} close-all
        # I win
        bind = $mainMod, P, exec, ${wl-paste} | sgpt --model="gpt-4o" "Respond with the correct answer to the following question." | ${wl-copy}
        # notes

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
      #experimental:explicit_sync = true
    };
  };
}
