{ config, osConfig, pkgs, inputs, lib, ... }:
with lib;
let cfg = osConfig.custom.graphical.hyprland;
in {
  config = let
    # styles from https://github.com/khaneliman/khanelinix/blob/8375f8cfbe5bfd87565b4dc34c9d30630c17336d/modules/home/desktop/addons/waybar/default.nix
    base16 = config.stylix.base16Scheme;
    readAndReplace = path: replace: builtins.readFile (pkgs.replaceVars path replace);
    # base 1, 7, 0
    #theme = readAndReplace ./styles/theme.css { BASE="#5c4133"; BORDER="#fef1de"; TEXT="#dab353";};
    theme = builtins.readFile ./styles/theme.css;
    style = builtins.readFile ./styles/style.css;
    notificationsStyle = builtins.readFile ./styles/notifications.css;
    powerStyle = builtins.readFile ./styles/power.css;
    statsStyle = builtins.readFile ./styles/stats.css;
    workspacesStyle = builtins.readFile ./styles/workspaces.css;
  in lib.mkIf cfg.enable {

    home.file.".config/waybar" = {
      recursive = true;
      source = ../../.config/waybar;
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
          #"hyprland/window"
        ];
        modules-center = [ ];
        modules-right = [ "group/stats" "group/other" ];
        "group/stats" = {
          "orientation" = "horizontal";
          "modules" = [ "network" "cpu" "memory" "disk" "temperature" ] 
              ++ lib.optionals osConfig.custom.hardware.nvidia.enable [ "custom/nvidia" ]
              ++ lib.optionals osConfig.custom.hardware.amd-gpu.enable [ "custom/amd-gpu" ];
        };
        "group/other" = {
          "orientation" = "horizontal";
          "modules" =
            [ "tray" "backlight" "pulseaudio" "mpris" "battery" "clock" ];
        };
        "cpu" = {
          "format" = "  {usage}%";
          "tooltip" = true;
        };
        "disk" = { "format" = "  {percentage_used}%"; };
        "memory" = { "format" = "󰍛 {}%"; };

        "idle_inhibitor" = {
          "format" = "{icon} ";
          "format-icons" = {
            "activated" = "";
            "deactivated" = "";
          };
        };

        "keyboard-state" = {
          "numlock" = true;
          "capslock" = true;
          "format" = "{icon} {name}";
          "format-icons" = {
            "locked" = "";
            "unlocked" = "";
          };
        };

        "network" = {
          "interval" = 2;
          "format-wifi" = "  󰜮 {bandwidthDownBytes} 󰜷 {bandwidthUpBytes}";
          "format-ethernet" = "󰈀  󰜮 {bandwidthDownBytes} 󰜷 {bandwidthUpBytes}";
          "tooltip-format" = " {ifname} via {gwaddr}";
          "format-linked" = "󰈁 {ifname} (No IP)";
          "format-disconnected" = " Disconnected";
          "format-alt" = "{ifname}: {ipaddr}/{cidr}";
        };
        "pulseaudio" = {
          "format" = "{volume}% {icon}";
          "format-bluetooth" = "{volume}% {icon}";
          "format-muted" = "";
          "format-icons" = {
            "headphone" = " ";
            "hands-free" = " ";
            "headset" = " ";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [ "" "" ];
          };
          "scroll-step" = 1;
          "on-click" = "${pkgs.pavucontrol}/bin/pavucontrol";
          "ignored-sinks" = [ "Easy Effects Sink" ];
        };

        "pulseaudio/slider" = {
          "min" = 0;
          "max" = 100;
          "orientation" = "horizontal";
        };
        "temperature".critical-threshold = 80;
        "temperature".format = "{temperatureC}°C ";
        "temperature".interval = 5;
        "temperature".hwmon-path =
          lib.mkIf (osConfig.networking.hostName == "nix-laptop")
          "/sys/class/hwmon/hwmon6/temp1_input";
        "backlight".format = "{percent}% {icon}";
        "backlight".states = [ 0 50 ];
        "backlight".format-icons = [ "" "" ];
        "battery".states.good = 95;
        "battery".interval = 5;
        "battery".states.warning = 30;
        "battery".states.critical = 15;
        "battery".format = "{capacity}% / {power:.2}W  {icon}";
        "battery".format-icons = [ "" "" "" "" "" ];
        "clock" = {
          format = "{:%F %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          "calendar" = {
            "mode" = "year";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            "format" = {
              "months" = "<span color='#ffead3'><b>{}</b></span>";
              "days" = "<span color='#ecc6d9'><b>{}</b></span>";
              "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
              "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
              "today" = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
        };
        "mpris" = {
          "format" = "{player_icon} {dynamic}";
          "format-paused" = "{status_icon} <i>{dynamic}</i>";
          "title-len" = 35;
          "dynamic-len" = 35;
          "player-icons" = {
            "default" = "▶";
            "mpv" = "🎵";
          };
          "status-icons" = { "paused" = "⏸"; };
        };
        "custom/nvidia" = {
          "format" = "{}";
          "interval" = 5;
          "exec" = "~/.config/waybar/nvidia.sh";
          "exec-if" = "nvidia-smi";
        };
        "custom/amd-gpu" = {
          "format" = "{}";
          "interval" = 5;
          "exec" = "~/.config/waybar/amd-gpu.sh";
        };
        "tray".icon-size = 21;
        "tray".spacing = 10;
        "hyprland/window" = {
          "format" = "{}";
          "separate-outputs" = true;
        };

        "hyprland/workspaces" = {
          "disable-scroll" = true;
          "all-outputs" = false;
          "active-only" = false;
          "on-click" = "activate";
          "format" = "{icon} {windows}";
          "format-icons" = {
            "1" = "󰎤";
            "2" = "󰎧";
            "3" = "󰎪";
            "4" = "󰎭";
            "5" = "󰎱";
            "6" = "󰎳";
            "7" = "󰎶";
            "8" = "󰎹";
            "9" = "󰎼";
            "10" = "󰽽";
            "urgent" = "󱨇";
            "default" = "";
            "empty" = "󱓼";
          };
          # "format-window-separator" = "->";
          "window-rewrite-default" = "";
          "window-rewrite" = {
            "class<org.keepassxc.KeePassXC>" = "󰢁";
            "class<Caprine>" = "󰈎";
            "class<Github Desktop>" = "󰊤";
            "class<Godot>" = "";
            "class<Mysql-workbench-bin>" = "";
            "class<Slack>" = "󰒱";
            "class<code>" = "󰨞";
            "class<codium>" = "󰨞";
            "code-url-handler" = "󰨞";
            "class<discord>" = "󰙯";
            "class<firefox>" = "";
            "class<firefox-beta>" = "";
            "class<firefox-developer-edition>" = "";
            "class<firefox> title<.*github.*>" = "";
            "class<firefox> title<.*twitch|youtube|plex|tntdrama|bally sports.*>" =
              "";
            "class<kitty>" = "";
            "class<org.wezfurlong.wezterm>" = "";
            "class<mediainfo-gui>" = "󱂷";
            "class<org.kde.digikam>" = "󰄄";
            "class<org.telegram.desktop>" = "";
            "class<.pitivi-wrapped>" = "󱄢";
            "class<steam>" = "";
            "class<thunderbird>" = "";
            "class<virt-manager>" = "󰢹";
            "class<vlc>" = "󰕼";
            "class<thunar>" = "󰉋";
            "class<org.gnome.Nautilus>" = "󰉋";
            "class<Spotify>" = "";
            "title<Spotify Free>" = "";
            "class<libreoffice-draw>" = "󰽉";
            "class<libreoffice-writer>" = "";
            "class<libreoffice-calc>" = "󱎏";
            "class<libreoffice-impress>" = "󱎐";
            "class<teams-for-linux>" = "󰊻";
            "class<org.prismlauncher.PrismLauncher>" = "󰍳";
            "class<minecraft-launcher>" = "󰍳";
            "class<Postman>" = "󰛮";
            "class<jetbrains-idea>" = "";
            "class<Logseq>" = "";
            "class<brave-browser>" = "";
          };
        };
      };
      style =
        "${theme}${style}${notificationsStyle}${powerStyle}${statsStyle}${workspacesStyle}";
    };
  };
}
