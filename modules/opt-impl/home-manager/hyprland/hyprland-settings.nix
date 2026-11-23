{
  config,
  osConfig,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.hyprland;
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
    hyprctl --instance 0 "dispatch exec qylock-lock"
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
  lua = lib.generators.mkLuaInline;
  toLua = lib.generators.toLua { };
  mkCall = args: { _args = args; };
  mkBind =
    keys: dispatcher: flags:
    mkCall (
      [
        keys
        (lua dispatcher)
      ]
      ++ lib.optional (flags != { }) flags
    );
  execDispatcher = command: "hl.dsp.exec_cmd(${toLua command})";
  mkExecBind = keys: command: mkBind keys (execDispatcher command) { };
  mkRepeatExecBind = keys: command: mkBind keys (execDispatcher command) { repeating = true; };
  workspaceKey = workspace: if workspace == 10 then "0" else toString workspace;
in
{
  config = lib.mkIf cfg.enable {
    #programs.swaylock.enable = true;
    services.hyprpaper.enable = true;
    home.packages = [
      hyprlandFixLockscreen
      pkgs.hypridle
      pkgs.hyprshot
      pkgs.hyprpicker
    ];
    home.file.".config/hypr/monitor-config.js".source = ../../../../.config/hypr/monitor-config.js;
    home.file.".config/hypr/hyprpaper.conf".source = pkgs.writeText "hyprpaper.conf" ''
      wallpaper {
         monitor =
         path = ${config.stylix.image}
         fit_mode = cover
      }
    '';
    wayland.windowManager.hyprland =
      let
        rofi = "${pkgs.rofi}/bin/rofi";
        rofimoji = "${pkgs.rofimoji}/bin/rofimoji";
        kitty = "${pkgs.kitty}/bin/kitty";
        thunar = "${pkgs.thunar}/bin/thunar";
        lock-cmd =
          if config.custom.graphical.qylock.enable then "qylock-lock" else "${pkgs.hyprlock}/bin/hyprlock";
        hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
        hyprshot = "${pkgs.hyprshot}/bin/hyprshot";
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        zenity = "${pkgs.zenity}/bin/zenity";
        woomer = "${pkgs.woomer}/bin/woomer";
        brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
        wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
        wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
        dunstify = "${pkgs.dunst}/bin/dunstify";
        dunstctl = "${pkgs.dunst}/bin/dunstctl";
        pdfgrep = "${pkgs.pdfgrep}/bin/pdfgrep --cache";
        path = "~/synced/fh/master/governance/merged";
        node = "${pkgs.nodejs}/bin/node";
        set-monitor = "~/.config/hypr/monitor-config.js";
        ydotool = "${pkgs.ydotool}/bin/ydotool";
        wl-kbptr = "${pkgs.wl-kbptr}/bin/wl-kbptr";
        saved-screenshot-cmd = ''
          ${hyprshot} -z -s -m region -o $OUT -f $FILE && notify-send "Saved screenshot to $OUT/$FILE" -h string:image-path:$OUT/$FILE && echo "file://$(realpath $OUT/$FILE)" | wl-copy -t text/uri-list
        '';
        saved-screenshot-cmd-output = ''
          ${hyprshot} -z -s -m output -o $OUT -f $FILE && notify-send "Saved screenshot to $OUT/$FILE" -h string:image-path:$OUT/$FILE && echo "file://$(realpath $OUT/$FILE)" | wl-copy -t text/uri-list
        '';
        startupCommands = [
          { command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator &"; }
          { command = "dex --autostart --environment Hyprland"; }
          { command = "${pkgs.hypridle}/bin/hypridle &"; }
          { command = "${pkgs.ydotool}/bin/ydotoold &"; }
        ]
        ++ lib.optionals isPc [
          {
            command = "sleep 2 && discord";
            rules.workspace = "9 silent";
          }
          {
            command = "sleep 2 && discordcanary";
            rules.workspace = "9 silent";
          }
          {
            command = "firefox";
            rules.workspace = "10 silent";
          }
          { command = "xrandr --monitor ${monitor1} --primary"; }
          { command = "${pkgs.kop-llama-systray}/bin/kop-llama-systray &"; }
        ]
        ++ [
          { command = "sleep 3 && ${pkgs.waybar}/bin/waybar &"; }
          { command = "${restartPortals}"; }
        ];
        renderStartupCommand =
          entry:
          "hl.exec_cmd(${toLua entry.command}${lib.optionalString (entry ? rules) ", ${toLua entry.rules}"})";
      in
      {
        enable = true;
        configType = "lua";
        xwayland.enable = true;

        settings = {
          monitor =
            if isPc then
              [
                {
                  output = monitor2;
                  mode = "1920x1080@60";
                  position = "0x0";
                  scale = builtins.fromJSON scale;
                }
                {
                  output = monitor1;
                  mode = "2560x1440@144";
                  position = "1920x0";
                  scale = builtins.fromJSON scale;
                }
                {
                  output = "Unknown-1";
                  disabled = true;
                }
              ]
            else if isLaptop then
              [
                {
                  output = "eDP-1";
                  mode = "2256x1504@60";
                  position = "0x0";
                  scale = builtins.fromJSON scale;
                }
                {
                  output = "";
                  mode = "preferred";
                  position = "auto";
                  scale = "auto";
                }
              ]
            else
              [
                {
                  output = "";
                  mode = "preferred";
                  position = "auto";
                  scale = "auto";
                }
              ];

          workspace_rule = lib.optionals isPc (
            map
              (workspace: {
                workspace = toString workspace;
                monitor = if workspace <= 5 then monitor1 else monitor2;
              })
              [
                1
                2
                3
                4
                5
                9
                10
              ]
          );

          env =
            let
              env = name: value: {
                _args = [
                  name
                  (toString value)
                ];
              };

              mkEnv = attrs: attrs |> builtins.mapAttrs env |> builtins.attrValues;
            in
            mkEnv (
              {
                "XCURSOR_SIZE" = "24";
                "NIXOS_OZONE_WL" = "1";
                "GDK_SCALE" = scale;
                "SDL_VIDEO_DISPLAY_PRIORITY" = monitor1;
              }
              // lib.optionalAttrs config.custom.hardware.nvidia.enable {
                "LIBVA_DRIVER_NAME" = "nvidia";
                "GBM_BACKEND" = "nvidia-drm";
                "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
              }
            )
            ++ lib.optionals osConfig.programs.ssh.startAgent [
              (mkCall [
                "SSH_AUTH_SOCK"
                (lua ''os.getenv("XDG_RUNTIME_DIR") .. "/ssh-agent"'')
              ])
            ];

          config = {
            input = {
              kb_layout = osConfig.mainUser.layout;
              kb_variant = osConfig.mainUser.variant;
              kb_model = "";
              kb_options = "";
              kb_rules = "";
              follow_mouse = 1;
              float_switch_override_focus = 2;
              touchpad.natural_scroll = true;
              accel_profile = "flat";
              sensitivity = 0;
              repeat_delay = 250;
            };

            general = {
              gaps_in = 5;
              gaps_out = 5;
              border_size = 2;
              col = {
                active_border = {
                  colors = [
                    "rgba(33ccffee)"
                    "rgba(00ff99ee)"
                  ];
                  angle = 45;
                };
                inactive_border = "rgba(595959aa)";
              };
              layout = "dwindle";
              allow_tearing = true;
            };

            render.new_render_scheduling = true;
            misc = {
              middle_click_paste = false;
              enable_anr_dialog = false;
              disable_hyprland_logo = true;
            };
            ecosystem = {
              no_donation_nag = true;
              no_update_news = true;
            };
            xwayland.force_zero_scaling = true;
            decoration = {
              rounding = 0;
              blur.enabled = false;
              shadow = {
                enabled = false;
                range = 4;
                render_power = 3;
                color = "rgba(1a1a1aee)";
              };
            };
            animations.enabled = true;
            dwindle.preserve_split = true;
            master.new_status = "master";
          };

          animation = [
            {
              leaf = "workspaces";
              enabled = false;
            }
            {
              leaf = "windows";
              enabled = true;
              speed = 3;
              bezier = "default";
            }
          ];

          bind = [
            (mkExecBind "SUPER + Q" kitty)
            (mkBind "SUPER + C" "hl.dsp.window.close()" { })
            (mkExecBind "SUPER + SHIFT + L" lock-cmd)
            (mkExecBind "SUPER + M" "${zenity} --question --text='Quit Hyprland?' && hyprctl dispatch 'hl.dsp.exit()'")
            (mkExecBind "SUPER + E" thunar)
            (mkBind "SUPER + P" "hl.dsp.window.pin()" { })
            (mkExecBind "SUPER + SHIFT + P" "${hyprpicker} --autocopy")
            (mkBind "SUPER + F" "hl.dsp.window.fullscreen()" { })
            (mkBind "SUPER + V" "hl.dsp.window.float()" { })
            (mkBind "SUPER + T" "hl.dsp.group.toggle()" { })
            (mkBind "SUPER + TAB" "hl.dsp.group.next()" { })
            (mkBind "SUPER + SHIFT + TAB" "hl.dsp.group.prev()" { })
            (mkExecBind "SUPER + period" rofimoji)
            (mkExecBind "SUPER + Z" woomer)
            (mkExecBind "SUPER + S" ''echo "skip" | nc exposedvm.kopatz.dev 8888'')
            (mkExecBind "SUPER + SHIFT + R" ''hyprctl hyprpaper reload ,"$(ls -d ~/synced/default/dinge/Bg/* | shuf -n 1)"'')
            (mkExecBind "SUPER + SHIFT + W" "hyprctl hyprpaper reload ,${config.stylix.image}")
            (mkExecBind "Print" "${hyprshot} -s -z -m region --clipboard-only")
            (mkExecBind "SUPER + Print" "export OUT=/tmp && FILE=$(date +'%s_screenshot.png') && ${saved-screenshot-cmd}")
            (mkExecBind "SHIFT + Print" "export OUT=~/Pictures && FILE=$(date +'%s_screenshot.png') && ${saved-screenshot-cmd}")
            (mkExecBind "SUPER + SHIFT + Print" "export OUT=~/Pictures && FILE=$(date +'%s_screenshot.png') && ${saved-screenshot-cmd-output}")
            (mkExecBind "SUPER + SPACE" "${rofi} -modi drun -show drun -config ~/.config/rofi/rofidmenu.rasi")
            (mkExecBind "XF86AudioPlay" "${playerctl} play-pause")
            (mkExecBind "XF86AudioNext" "${playerctl} next")
            (mkExecBind "XF86AudioPrev" "${playerctl} previous")
            (mkBind "SUPER + U" "hl.dsp.window.pseudo()" { })
            (mkBind "SUPER + I" ''hl.dsp.layout("togglesplit")'' { })
            (mkBind "SUPER + left" ''hl.dsp.focus({ direction = "left" })'' { })
            (mkBind "SUPER + right" ''hl.dsp.focus({ direction = "right" })'' { })
            (mkBind "SUPER + up" ''hl.dsp.focus({ direction = "up" })'' { })
            (mkBind "SUPER + down" ''hl.dsp.focus({ direction = "down" })'' { })
            (mkBind "SUPER + CTRL + left" ''hl.dsp.window.move({ direction = "left" })'' { })
            (mkBind "SUPER + CTRL + right" ''hl.dsp.window.move({ direction = "right" })'' { })
            (mkBind "SUPER + CTRL + up" ''hl.dsp.window.move({ direction = "up" })'' { })
            (mkBind "SUPER + CTRL + down" ''hl.dsp.window.move({ direction = "down" })'' { })
            (mkBind "SUPER + h" ''hl.dsp.focus({ direction = "left" })'' { })
            (mkBind "SUPER + l" ''hl.dsp.focus({ direction = "right" })'' { })
            (mkBind "SUPER + k" ''hl.dsp.focus({ direction = "up" })'' { })
            (mkBind "SUPER + j" ''hl.dsp.focus({ direction = "down" })'' { })
            (mkBind "SUPER + CTRL + h" ''hl.dsp.window.move({ direction = "left" })'' { })
            (mkBind "SUPER + CTRL + l" ''hl.dsp.window.move({ direction = "right" })'' { })
            (mkBind "SUPER + CTRL + k" ''hl.dsp.window.move({ direction = "up" })'' { })
            (mkBind "SUPER + CTRL + j" ''hl.dsp.window.move({ direction = "down" })'' { })
            (mkBind "SUPER + B" ''hl.dsp.global("waybar:toggle_bar")'' { })
          ]
          ++ map (
            workspace:
            mkBind "SUPER + ${workspaceKey workspace}" "hl.dsp.focus({ workspace = ${toString workspace} })" { }
          ) (lib.range 1 10)
          ++ map (
            workspace:
            mkBind "SUPER + SHIFT + ${workspaceKey workspace}"
              "hl.dsp.window.move({ workspace = ${toString workspace} })"
              { }
          ) (lib.range 1 10)
          ++ [
            (mkBind "SUPER + X" ''hl.dsp.workspace.toggle_special("")'' { })
            (mkBind "SUPER + SHIFT + X" ''hl.dsp.window.move({ workspace = "special" })'' { })
            (mkBind "SUPER + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'' { })
            (mkBind "SUPER + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'' { })
            (mkBind "ALT + Tab" "hl.dsp.window.cycle_next()" { })
            (mkRepeatExecBind "XF86MonBrightnessUp" "${brightnessctl} s +5%")
            (mkRepeatExecBind "XF86MonBrightnessDown" "${brightnessctl} s 5%-")
            (mkRepeatExecBind "XF86AudioRaiseVolume" "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+")
            (mkRepeatExecBind "XF86AudioLowerVolume" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
            (mkRepeatExecBind "XF86AudioMute" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
            (mkRepeatExecBind "XF86AudioMicMute" "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
            (mkBind "SUPER + SHIFT + left" "hl.dsp.window.resize({ x = -30, y = 0, relative = true })" {
              repeating = true;
            })
            (mkBind "SUPER + SHIFT + right" "hl.dsp.window.resize({ x = 30, y = 0, relative = true })" {
              repeating = true;
            })
            (mkBind "SUPER + SHIFT + up" "hl.dsp.window.resize({ x = 0, y = -30, relative = true })" {
              repeating = true;
            })
            (mkBind "SUPER + SHIFT + down" "hl.dsp.window.resize({ x = 0, y = 30, relative = true })" {
              repeating = true;
            })
            (mkBind "SUPER + SHIFT + h" "hl.dsp.window.resize({ x = -30, y = 0, relative = true })" {
              repeating = true;
            })
            (mkBind "SUPER + SHIFT + l" "hl.dsp.window.resize({ x = 30, y = 0, relative = true })" {
              repeating = true;
            })
            (mkBind "SUPER + SHIFT + k" "hl.dsp.window.resize({ x = 0, y = -30, relative = true })" {
              repeating = true;
            })
            (mkBind "SUPER + SHIFT + j" "hl.dsp.window.resize({ x = 0, y = 30, relative = true })" {
              repeating = true;
            })
            (mkBind "SUPER + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
            (mkBind "SUPER + mouse:273" "hl.dsp.window.resize()" { mouse = true; })
            (mkBind "SUPER + A" ''hl.dsp.submap("notes")'' { })
            (mkBind "SUPER + W" ''hl.dsp.submap("cursor")'' { })
          ];

          window_rule = [
            {
              match.class = "zenity";
              float = true;
            }
            {
              match.class = "zenity";
              center = true;
            }
            {
              match.class = "steam_app_.*";
              workspace = "1";
            }
            {
              match.title = "Trove";
              allows_input = true;
            }
            {
              match.class = "(steam_app_107410)";
              stay_focused = true;
            }
            {
              match.class = "^tetrio-desktop$";
              immediate = true;
            }
            {
              match.class = "thunar";
              opacity = "0.9";
            }
            {
              match = {
                class = "discord";
                fullscreen = false;
              };
              opacity = "0.9";
            }
            {
              match.title = "cava";
              opacity = "0.1";
            }
            {
              match.title = "Picture-in-Picture";
              float = true;
            }
            {
              match.title = "Picture-in-Picture";
              suppress_event = "maximize";
            }
            {
              match.workspace = 5;
              no_screen_share = true;
            }
            {
              match.workspace = 7;
              no_screen_share = true;
            }
          ];

        };

        submaps = {
          notes.settings.bind = [
            (mkExecBind "SUPER + M" ''hyprctl keyword monitor ",preferred,auto,1,mirror,${monitor1}" && ${dunstify} "Mirroring enabled"'')
            (mkExecBind "SUPER + R" ''hyprctl keyword monitor ",preferred,auto,auto" && ${dunstify} "Mirroring disabled"'')
            (mkExecBind "SUPER + P" "${node} ${set-monitor}")
            (mkExecBind "SUPER + A" ''${wl-paste} | xargs -I {} ${pdfgrep} -B 15 -h -i "{}" ${path}/*.pdf | sed 's/[ \t]*$//' | ${wl-copy}'')
            (mkExecBind "SUPER + B" ''${wl-paste} | xargs -I {} ${pdfgrep} -A 15 -h -i "{}" ${path}/*.pdf | sed 's/[ \t]*$//' | ${wl-copy}'')
            (mkExecBind "SUPER + C" ''${wl-paste} | xargs -I {} ${pdfgrep} -C 15 -h -i "{}" ${path}/*.pdf | sed 's/[ \t]*$//' | ${wl-copy}'')
            (mkExecBind "SUPER + T" ''${wl-paste} | sed 's/[ \t]*$//' | sed 's/^[ \t]*//' | sed '/^[[:space:]]*$/d' | ${wl-copy}'')
            (mkExecBind "SUPER + E" ''${wl-paste} | sed 's/[ \t]*$//' | ${wl-copy}'')
            (mkExecBind "SUPER + N" ''${dunstify} "$(${wl-paste})"'')
            (mkExecBind "SUPER + D" "${dunstctl} close-all")
            (mkExecBind "SUPER + W" ''${wl-paste} | claude -p --model opus --system-prompt "Respond with the correct answer to the following question. Do not provide detailed explanations or answer in markdown, only tell me the correct answer if possible." | ${wl-copy} && ${dunstify} -t 150 Done'')
            (mkExecBind "SUPER + SHIFT + W" ''${hyprshot} -s --mode active --mode output -o /tmp -f question.png; claude -p --model opus --allowed-tools "Read,WebFetch,WebSearch" --system-prompt "Respond with the correct answer to the question in the screenshot. Do not provide detailed explanations or answer in markdown, only tell me the correct answer (or answers if it there are multiple)." "Read /tmp/question.png and answer the question in it" | ${wl-copy} && ${dunstify} -t 150 Done'')
            (mkExecBind "SUPER + CTRL + W" ''${hyprshot} -s --mode region -o /tmp -f question.png; claude -p --model opus --allowed-tools "Read,WebFetch,WebSearch" --system-prompt "Respond with the correct answer to the question in the screenshot. Do not provide detailed explanations or answer in markdown, only tell me the correct answer (or answers if it there are multiple)." "Read /tmp/question.png and answer the question in it" | ${wl-copy} && ${dunstify} -t 150 Done'')
            (mkExecBind "SUPER + E" ''${wl-paste} | claude -p --model sonnet --system-prompt "Respond with the correct answer to the following question. Do not provide detailed explanations or answer in markdown, only tell me the correct answer if possible." | ${wl-copy} && ${dunstify} -t 150 Done'')
            (mkExecBind "SUPER + SHIFT + E" ''${hyprshot} -s --mode active --mode output -o /tmp -f question.png; claude -p --model sonnet --allowed-tools "Read,WebFetch,WebSearch" --system-prompt "Respond with the correct answer to the question in the screenshot. Do not provide detailed explanations or answer in markdown, only tell me the correct answer (or answers if it there are multiple)." "Read /tmp/question.png and answer the question in it" | ${wl-copy} && ${dunstify} -t 150 Done'')
            (mkExecBind "SUPER + CTRL + E" ''${hyprshot} -s --mode region -o /tmp -f question.png; claude -p --model sonnet --allowed-tools "Read,WebFetch,WebSearch" --system-prompt "Respond with the correct answer to the question in the screenshot. Do not provide detailed explanations or answer in markdown, only tell me the correct answer (or answers if it there are multiple)." "Read /tmp/question.png and answer the question in it" | ${wl-copy} && ${dunstify} -t 150 Done'')
            (mkExecBind "SUPER + S" "pgrep claude && ${dunstify} -t 150 Working || ${dunstify} -t 150 Not_found")
            (mkExecBind "SUPER + K" "kill -9 $(pgrep claude) && ${dunstify} -t 150 Killed || ${dunstify} -t 150 Not_found")
            (mkExecBind "SUPER + F" ''${wl-paste} | ~/synced/default/scripts/fragen --path ~/synced/fh/master/governance/merged/fragen.md | ${wl-copy} && ${dunstctl} close-all && ${dunstify} "$(${wl-paste})"'')
            (mkExecBind "SUPER + SHIFT + F" ''~/synced/default/scripts/fragen --next | ${wl-copy} && ${dunstctl} close-all && ${dunstify} "$(${wl-paste})"'')
            (mkExecBind "SUPER + 1" "cat ~/synced/fh/master/governance/merged/1.txt | ${wl-copy}")
            (mkExecBind "SUPER + 2" "${wl-paste} | xargs -I _ rg -i _ ~/synced/fh/master/governance/merged/1.txt | ${wl-copy}")
            (mkBind "escape" ''hl.dsp.submap("reset")'' { })
          ];

          cursor.settings.bind = [
            (mkExecBind "a" "hyprctl dispatch submap reset && ${wl-kbptr} && hyprctl dispatch submap cursor")
            (mkRepeatExecBind "J" "${ydotool} mousemove -- 0 10")
            (mkRepeatExecBind "K" "${ydotool} mousemove -- 0 -10")
            (mkRepeatExecBind "L" "${ydotool} mousemove -- 10 0")
            (mkRepeatExecBind "H" "${ydotool} mousemove -- -10 0")
            (mkRepeatExecBind "down" "${ydotool} mousemove -- 0 10")
            (mkRepeatExecBind "up" "${ydotool} mousemove -- 0 -10")
            (mkRepeatExecBind "right" "${ydotool} mousemove -- 10 0")
            (mkRepeatExecBind "left" "${ydotool} mousemove -- -10 0")
            (mkRepeatExecBind "SHIFT + J" "${ydotool} mousemove -- 0 50")
            (mkRepeatExecBind "SHIFT + K" "${ydotool} mousemove -- 0 -50")
            (mkRepeatExecBind "SHIFT + L" "${ydotool} mousemove -- 50 0")
            (mkRepeatExecBind "SHIFT + H" "${ydotool} mousemove -- -50 0")
            (mkRepeatExecBind "SHIFT + down" "${ydotool} mousemove -- 0 50")
            (mkRepeatExecBind "SHIFT + up" "${ydotool} mousemove -- 0 -50")
            (mkRepeatExecBind "SHIFT + right" "${ydotool} mousemove -- 50 0")
            (mkRepeatExecBind "SHIFT + left" "${ydotool} mousemove -- -50 0")
            (mkExecBind "S" "${ydotool} click 0xC0")
            (mkExecBind "D" "${ydotool} click 0xC2")
            (mkExecBind "F" "${ydotool} click 0xC1")
            (mkRepeatExecBind "E" "${ydotool} mousemove -w -- 0 -1")
            (mkRepeatExecBind "R" "${ydotool} mousemove -w -- 0 1")
            (mkRepeatExecBind "Q" "${ydotool} mousemove -w -- 0 -5")
            (mkRepeatExecBind "W" "${ydotool} mousemove -w -- 0 5")
            (mkRepeatExecBind "T" "${ydotool} mousemove -w -- 1 0")
            (mkRepeatExecBind "G" "${ydotool} mousemove -w -- -1 0")
            (mkRepeatExecBind "SHIFT + T" "${ydotool} mousemove -w -- 5 0")
            (mkRepeatExecBind "SHIFT + G" "${ydotool} mousemove -w -- -5 0")
            (mkBind "escape" ''hl.dsp.submap("reset")'' { })
          ];
        };

        extraConfig = ''
          hl.on("hyprland.start", function()
          ${lib.concatMapStringsSep "\n" renderStartupCommand startupCommands}
          end)
        '';
      };
  };
}
