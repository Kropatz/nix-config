{ config, osConfig, pkgs, inputs, lib, ... }:
with lib;
let
    cfg = osConfig.custom.graphical.hyprland;
in
{
  config = let
    # styles from https://github.com/khaneliman/khanelinix/blob/8375f8cfbe5bfd87565b4dc34c9d30630c17336d/modules/home/desktop/addons/waybar/default.nix
    theme = builtins.readFile ./styles/catppuccin.css;
    style = builtins.readFile ./styles/style.css;
    notificationsStyle = builtins.readFile ./styles/notifications.css;
    powerStyle = builtins.readFile ./styles/power.css;
    statsStyle = builtins.readFile ./styles/stats.css;
    workspacesStyle = builtins.readFile ./styles/workspaces.css;
  in lib.mkIf cfg.enable {
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
	  #"hyprland/window"
	];
	modules-center = [];
	modules-right = [
          "group/stats"
	  "group/other"
	];
	"cpu" = {
	  "format" = "  {usage}%";
	  "tooltip" = true;
	};
	"disk" = {
	  "format" = "  {percentage_used}%";
  	};
  	"memory" = {
  	  "format" = "󰍛 {}%";
  	};

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
  	  "format-muted" = "🚫";
  	  "format-icons" = {
  	    "headphone" = "";
  	    "hands-free" = "";
  	    "headset" = "";
  	    "phone" = "";
  	    "portable" = "";
  	    "car" = "";
  	    "default" = [
  	      ""
  	      ""
  	    ];
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
	"backlight".format = "{percent}% {icon}";
	"backlight".states = [0 50];
	"backlight".format-icons = ["" ""];
	"battery".states.good = 95;
	"battery".states.warning = 30;
	"battery".states.critical = 15;
	"battery".format = "{capacity}% / {power:.2}W  {icon}";
	"battery".format-icons = ["" "" "" "" ""];
	"clock".format = "{:%F %H:%M}";
	"clock".tooltip-format = "<tt><small>{calendar}</small></tt>";
	"tray".icon-size = 21;
	"tray".spacing = 10;
        "group/stats" = {
          "orientation" = "horizontal";
          "modules" = [
            "network"
            "cpu"
            "memory"
            "disk"
            "temperature"
          ];
        };
        "group/other" = {
          "orientation" = "horizontal";
          "modules" = [
	    "tray"
	    "backlight"
	    "pulseaudio"
	    "battery"
	    "clock"
          ];
        };
	"hyprland/window" = {
	  "format" = "{}";
  	  "separate-outputs" = true;
  	};

  	"hyprland/workspaces" = {
          "disable-scroll" = true;
  	  "all-outputs" = true;
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
  	    "code-url-handler" = "󰨞";
  	    "class<discord>" = "󰙯";
  	    "class<firefox>" = "";
  	    "class<firefox-beta>" = "";
  	    "class<firefox-developer-edition>" = "";
  	    "class<firefox> title<.*github.*>" = "";
  	    "class<firefox> title<.*twitch|youtube|plex|tntdrama|bally sports.*>" = "";
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
  	  };
  	};
      };
      style = "${theme}${style}${notificationsStyle}${powerStyle}${statsStyle}${workspacesStyle}";
    };
  };
}
