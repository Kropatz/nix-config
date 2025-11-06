{
  config,
  osConfig,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  cfg = osConfig.custom.graphical.hyprland;
  isPc = osConfig.networking.hostName == "kop-pc";
  isLaptop = osConfig.networking.hostName == "framework";
  restartPortals = pkgs.writeShellScript "restart-portals" ''
    #!/usr/bin/env bash
    systemctl --user restart xdg-desktop-portal-gtk
    systemctl --user restart xdg-desktop-portal-hyprland
    sleep 4
    systemctl --user restart xdg-desktop-portal
  '';
  hyprlandFixLockscreen = pkgs.writeShellScriptBin "hyprland-fix-lockscreen" ''
    #!/usr/bin/env bash
    hyprctl --instance 0 "keyword misc:allow_session_lock_restore 1"
    hyprctl --instance 0 "dispatch exec hyprlock"
  '';
  scale = if isLaptop then "1.33333" else "1";
  monitor1 =
    if isPc then
      "DP-1"
    else if isLaptop then
      "eDP-1"
    else
      "eDP-1";
  monitor2 = "HDMI-A-1";
in
{
  config = lib.mkIf cfg.enable {
    #programs.swaylock.enable = true;
    services.hyprpaper.enable = true;
    home.packages = [ hyprlandFixLockscreen ];
    home.file.".config/hypr/monitor-config.js".source = ../../.config/hypr/monitor-config.js;
    wayland.windowManager.hyprland = {
      enable = true;
      #enableNvidiaPatches = true;
      xwayland.enable = true;
      #plugins = [ pkgs.hyprlandPlugins.hyprscrolling ];
      settings = {
        #
        # Please note not all available settings / options are set here.
        # For a full list, see the wiki
        #

        # See https://wiki.hyprland.org/Configuring/Monitors/
        monitor =
          if isPc then
            [
              "${monitor2},1920x1080@60,0x0,${scale}"
              "${monitor1},2560x1440@144,1920x0,${scale}"
              "Unknown-1,disable"
            ]
          else if isLaptop then
            [
              # laptop
              "eDP-1,2256x1504@60,0x0,${scale}"
              #"DP-3,1920x1080@60,1920x0,1"
              #",preferred,auto,1,mirror,eDP-1"
              ",preferred,auto,auto"
            ]
          else
            [
              # Default
              ",preferred,auto,auto"
            ];

        workspace = lib.lists.optionals (osConfig.networking.hostName == "kop-pc") [
          "1,monitor:${monitor1}"
          "2,monitor:${monitor1}"
          "3,monitor:${monitor1}"
          "4,monitor:${monitor1}"
          "5,monitor:${monitor1}"
          "9,monitor:${monitor2}"
          "10,monitor:${monitor2}"
        ];

        # See https://wiki.hyprland.org/Configuring/Keywords/ for more

        # Execute your favorite apps at launch
        # exec-once = waybar & hyprpaper & firefox

        # Source a file (multi-file configs)
        # source = ~/.config/hypr/myColors.conf

        # Some default env vars.
        env = [
          "XCURSOR_SIZE,24"
          "NIXOS_OZONE_WL,1"
          "GDK_SCALE,${scale}"
        ]
        ++ lib.optionals osConfig.custom.hardware.nvidia.enable [
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

          touchpad = {
            natural_scroll = true;
          };

          accel_profile = "flat";
          sensitivity = 0;
          repeat_delay = 250;
        };

        #cursor = { no_hardware_cursors = true; };

        #render = {
        #  explicit_sync = 1;
        #  explicit_sync_kms = 0;
        #};

        general = {
          # See https://wiki.hyprland.org/Configuring/Variables

          gaps_in = 5;
          gaps_out = 5;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";

          layout = "dwindle";
          #layout = "scrolling";
          allow_tearing = true;
        };

        render = {
          new_render_scheduling = true;
        };
        misc = {
          vfr = true;
          middle_click_paste = false;
          enable_anr_dialog = false;
          disable_hyprland_logo = true;
        };
        xwayland = lib.mkIf isPc { force_zero_scaling = true; };

        decoration = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          #rounding = 10;
          rounding = 0;
          #blur = yes
          #blur_size = 3
          #blur_passes = 1
          #blur_new_optimizations = on
          blur = {
            enabled = false;
          };
          shadow = {
            enabled = false;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };
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
          animation = [ "workspaces, 0" ];
        };

        dwindle = {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true; # you probably want this
        };

        master = {
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          #new_is_master = true;
          new_status = "master";
        };

        gestures = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          # doesnt exist anymore TODO: change
          #workspace_swipe = true;
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
        bind =
          let
            rofi = "${pkgs.rofi}/bin/rofi";
            rofimoji = "${pkgs.rofimoji}/bin/rofimoji";
            kitty = "${pkgs.kitty}/bin/kitty";
            #dolphin = "${pkgs.dolphin}/bin/dolphin";
            thunar = "${pkgs.xfce.thunar}/bin/thunar";
            wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
            wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
            grimblast = "${pkgs.grimblast}/bin/grimblast";
            saved-screenshot-cmd = ''
              ${grimblast} --freeze save area $OUT && notify-send "Saved screenshot to $OUT" -h string:image-path:$OUT && echo "file://$(realpath $OUT)" | wl-copy -t text/uri-list
            '';
            pdfgrep = "${pkgs.pdfgrep}/bin/pdfgrep";
            brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
            #swaylock = "${pkgs.swaylock}/bin/swaylock";
            hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
            playerctl = "${pkgs.playerctl}/bin/playerctl";
            peek = "${pkgs.peek}/bin/peek";
            zenity = "${pkgs.zenity}/bin/zenity";
            woomer = "${pkgs.woomer}/bin/woomer";
          in
          [
            "$mainMod, Q, exec, ${kitty}"
            "$mainMod, C, killactive"
            #"$mainMod, L, exec, ${swaylock} -f -c 000000"
            "$mainMod, L, exec, ${hyprlock}"
            "$mainMod, M, exec, ${zenity} --question --text='Quit Hyprland?' && hyprctl dispatch exit"
            "$mainMod, E, exec, ${thunar}"
            "$mainMod, P, pin"
            "$mainMod, F, fullscreen"
            "$mainMod, V, togglefloating"
            "$mainMod, T, togglegroup"
            "$mainMod, I, exec, ${rofi} -show drun -show-icons"
            "$mainMod, period, exec, ${rofimoji}"
            "$mainMod, Z, exec, ${woomer}"
            ''$mainMod, S, exec, echo "skip" | nc kopatz.dev 8888''
            ''$mainMod, R, exec, hyprctl hyprpaper reload ,"$(ls -d ~/synced/default/dinge/Bg/* | shuf -n 1)"''
            "$mainMod, W, exec, hyprctl hyprpaper reload ,${config.stylix.image}"
            "        , Print, exec, ${grimblast} --freeze copy area"
            ''$mainMod, Print, exec, export OUT=/tmp/$(date +'%s_grim.png') && ${saved-screenshot-cmd}''
            ''Shift_L, Print, exec, export OUT=~/Pictures/$(date +'%s_grim.png') && ${saved-screenshot-cmd}''
            #"$mainMod, G, exec, ${peek}" # record gif
            "$mainMod, SPACE, exec, ${rofi} -modi drun -show drun -config ~/.config/rofi/rofidmenu.rasi"
            " , XF86AudioPlay, exec, ${playerctl} play-pause"
            " , XF86AudioNext, exec, ${playerctl} next"
            " , XF86AudioPrev, exec, ${playerctl} previous"
            "$mainMod, U, pseudo" # dwindle
            "$mainMod, J, togglesplit" # dwindle
            # Move focus with mainMod + arrow keys
            "$mainMod, left, movefocus, l"
            "$mainMod, right, movefocus, r"
            "$mainMod, up, movefocus, u"
            "$mainMod, down, movefocus, d"
            "$mainMod CTRL, left, movewindow, l"
            "$mainMod CTRL, right, movewindow, r"
            "$mainMod CTRL, up, movewindow, u"
            "$mainMod CTRL, down, movewindow, d"

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
            # "ALT, Tab, bringactivetotop,"
          ];

        # e = repeat when held
        binde =
          let
            brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";

          in
          [
            " , XF86MonBrightnessUp, exec, ${brightnessctl} s +5%"
            " , XF86MonBrightnessDown, exec, ${brightnessctl} s 5%-"
            # Example volume button that allows press and hold, volume limited to 150%
            " , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
            # Example volume button that will activate even while an input inhibitor is active
            " , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            " , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            " , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            "$mainMod SHIFT, left, resizeactive, -30 0"
            "$mainMod SHIFT, right, resizeactive, 30 0"
            "$mainMod SHIFT, up, resizeactive, 0 -30"
            "$mainMod SHIFT, down, resizeactive, 0 30"
          ];

        bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        windowrule = [
          "float, class:zenity"
          "center, class:zenity"
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
          "stayfocused,class:(steam_app_107410)"
          "immediate, class:^tetrio-desktop$"
          "opacity 0.9, class:thunar"
          "opacity 0.9, class:discord, fullscreen:0"
          "opacity 0.1, title:cava"
          "float, title:Picture-in-Picture"
          "suppressevent maximize, title:Picture-in-Picture"
        ];

        exec-once = [
          "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator &"
          "dex --autostart --environment Hyprland"
          "${pkgs.hypridle}/bin/hypridle &"
          #"${pkgs.dunst}/bin/dunst &"
        ]
        ++ lib.lists.optionals (osConfig.networking.hostName == "kop-pc") [
          "[workspace 9 silent] sleep 2 && discord"
          "[workspace 9 silent] sleep 2 && discordcanary"
          "[workspace 10 silent] firefox"
          "xrandr --monitor ${monitor1} --primary"
        ]
        ++ [
          "sleep 3 && ${pkgs.waybar}/bin/waybar &"
          "${restartPortals}"
        ];
      };
      extraConfig =
        let
          wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
          wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
          dunstify = "${pkgs.dunst}/bin/dunstify";
          dunstctl = "${pkgs.dunst}/bin/dunstctl";
          pdfgrep = "${pkgs.pdfgrep}/bin/pdfgrep --cache";
          path = "~/synced/fh/master/ot_fundamentals_and_security/merged";
          node = "${pkgs.nodejs}/bin/node";
          set-monitor = "~/.config/hypr/monitor-config.js";
          answer = "${pkgs.answer}/bin/answer";
        in
        ''
          bind = $mainMod, A, submap, notes

          submap = notes
          bind = $mainMod, M, exec, hyprctl keyword monitor ",preferred,auto,1,mirror,${monitor1}" && ${dunstify} "Mirroring enabled"
          bind = $mainMod, R, exec, hyprctl keyword monitor ",preferred,auto,auto" && ${dunstify} "Mirroring disabled"
          bind = $mainMod, P, exec, ${node} ${set-monitor}
          ## below
          bind = $mainMod, B, exec, ${wl-paste} | xargs -I {} ${pdfgrep} -B 15 -h -i "{}" ${path}/*.pdf | sed 's/[ \t]*$//' | ${wl-copy}
          ## above
          bind = $mainMod, A, exec, ${wl-paste} | xargs -I {} ${pdfgrep} -A 15 -h -i "{}" ${path}/*.pdf | sed 's/[ \t]*$//' | ${wl-copy}
          ## context
          bind = $mainMod, C, exec, ${wl-paste} | xargs -I {} ${pdfgrep} -C 15 -h -i "{}" ${path}/*.pdf | sed 's/[ \t]*$//' | ${wl-copy}
          ## trim
          bind = $mainMod, T, exec, ${wl-paste} | sed 's/[ \t]*$//' | sed 's/^[ \t]*//' | sed '/^[[:space:]]*$/d' | ${wl-copy}
          bind = $mainMod, N, exec, ${dunstify} "$(${wl-paste})"
          bind = $mainMod, D, exec, ${dunstctl} close-all
          ## I win
          bind = $mainMod, W, exec, ${wl-paste} | ${answer} "Respond with the correct answer to the following question." | ${wl-copy} && ${dunstify} -t 150 Done
          ## notes

          #bind = $mainMod, 2, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
          #bind = $mainMod, 3, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
          #bind = $mainMod, 4, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
          #bind = $mainMod, 5, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
          #bind = $mainMod, 6, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
          #bind = $mainMod, 7, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
          #bind = $mainMod, 8, exec, cat ~/Nextcloud/test.txt | ${wl-copy}
          #bind = $mainMod, 0, exec, cat ~/Nextcloud/test.txt | ${wl-copy}

          bind = , escape, submap, reset
          submap = reset

        '';
      #experimental:explicit_sync = true
    };
  };
}
