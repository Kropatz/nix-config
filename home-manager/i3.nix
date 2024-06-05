{ pkgs, config, ... }: {
  home.file.".config/i3" = {
    enable = true;
    recursive = true;
    source = ../.config/i3;
    target = ".config/i3";
  };

  home.file.".config/picom" = {
    enable = true;
    recursive = true;
    source = ../.config/picom;
    target = ".config/picom";
  };

  home.file.".config/wallpapers" = {
    enable = true;
    recursive = true;
    source = ../.config/wallpapers;
    target = ".config/wallpapers";
  };

  home.file.".config/polybar" = {
    enable = true;
    recursive = true;
    source = ../.config/polybar;
    target = ".config/polybar";
  };
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      pulseSupport = true;
      i3Support = true;
    };
    script = "polybar &";
    config = {
      "bar/main" = {
        monitor = "\${env:MONITOR:}";
        bottom = true;
        width = "100%";
        height = "22pt";
        radius = 0;
        # offset-y = -5;
        # offset-y = "5%";
        # dpi = 96;
        background = config.stylix.base16Scheme.base01;
        foreground = config.stylix.base16Scheme.base05;
        line-size = "3pt";
        font-0 = "Noto Sans:size=11;1";
        font-1 = "Hack-Regular.ttf: Hack:style=Regular";
        font-2 = "Noto Sans CJK JP:style=Regular";
        border-top-size = 0;
        border-right-size = 0;
        border-left-size = 0;
        border-bottom-size = 0; # "4pt";
        border-color = config.stylix.base16Scheme.base00;
        padding-left = 2;
        padding-right = 2;
        module-margin = 1;
        modules-left = "i3";
        modules-center = "xwindow";
        modules-right = "network memory cpu cpu-temp gpu pulseaudio date tray";
        cursor-click = "pointer";
        cursor-scroll = "ns-resize";
        enable-ipc = true;
        #tray-position = "right";
        # wm-restack = "generic";
        # wm-restack = "bspwm";
        # wm-restack = "i3";
        # override-redirect = true;
      };
      "module/i3" = let padding = 2;
      in {
        type = "internal/i3";
        pin-workspaces = true;
        show-urgent = true;
        strip-wsnumbers = true;
        index-sort = true;
        enable-click = true;
        wrapping-scroll = true;
        fuzzy-match = true;
        format = "<label-state> <label-mode>";
        label-focused = "%name%";
        label-focused-foreground = config.stylix.base16Scheme.base01;
        label-focused-background = config.stylix.base16Scheme.base05;
        label-focused-underline = config.stylix.base16Scheme.base03;
        label-focused-padding = padding;
        label-unfocused = "%name%";
        label-unfocused-padding = padding;
        label-visible = "%name%";
        label-visible-underline = config.stylix.base16Scheme.base01;
        label-visible-padding = padding;
        label-urgent = "%name%";
        label-urgent-foreground = config.stylix.base16Scheme.base00;
        label-urgent-background = config.stylix.base16Scheme.base08;
        label-urgent-underline = config.stylix.base16Scheme.base0F;
        label-urgent-padding = padding;
      };
      "module/xworkspaces" = {
        type = "internal/xworkspaces";
        label-active = "%name%";
        label-active-background = config.stylix.base16Scheme.base05;
        label-active-foreground = config.stylix.base16Scheme.base01;
        label-active-underline = config.stylix.base16Scheme.base03;
        label-active-padding = 1;
        label-occupied = "%name%";
        label-occupied-padding = 1;
        label-urgent = "%name%";
        label-urgent-background = config.stylix.base16Scheme.base08;
        label-urgent-padding = 1;
        label-empty = "%name%";
        label-empty-foreground = config.stylix.base16Scheme.base06;
        label-empty-padding = 1;
      };
      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:60:...%";
      };
      # "module/filesystem" = {
      # type = "internal/fs";
      # interval = 25;
      # mount-0 = "/";
      # label-mounted = "%{F#F0C674}%mountpoint%%{F-} %percentage_used%%";
      # label-unmounted = "%mountpoint% not mounted";
      # label-unmounted-foreground = colors.disabled;
      # };
      "module/network" = {
        type = "internal/network";
        interface-type = "wired";
        interval = 3;
        accumulate-stats = true;
        format-connected = "<label-connected>";
        format-connected-foreground = config.stylix.base16Scheme.base0B;
        format-disconnected = "<label-disconnected>";
        format-diconnected-foreground = config.stylix.base16Scheme.base08;
        label-connected = "%ifname% %netspeed%";
        label-disconnected = "";
      };
      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        # format-volume-prefix = "VOL ";
        # format-volume-prefix-foreground = colors.primary;
        format-volume = "<ramp-volume> <label-volume>";
        # format-volume-background = colors.background;
        # label-volume-background = colors.background;
        format-volume-foreground = config.stylix.base16Scheme.base09;
        label-volume = "%percentage%%";
        label-muted = "sound ---";
        label-muted-foreground = config.stylix.base16Scheme.base09;
        #ramp-volume-0 = "";
        #ramp-volume-1 = "󰕾";
        #ramp-volume-2 = "";

        ramp-volume-0 = "sound";
        ramp-volume-1 = "sound";
        ramp-volume-2 = "sound";
        click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
      };
      # "module/xkeyboard" = {
      # type = "internal/xkeyboard";
      # blacklist-0 = "num lock";
      # label-layout = "%layout%";
      # label-layout-foreground = colors.primary;
      # label-indicator-padding = 2;
      # label-indicator-margin = 1;
      # label-indicator-foreground = colors.background;
      # label-indicator-background = colors.secondary;
      # };
      "module/memory" = {
        type = "internal/memory";
        interval = 3;
        format-prefix = "RAM ";
        format-prefix-foreground = config.stylix.base16Scheme.base0C;
        label = "%percentage_used:2%%";
      };
      "module/cpu" = {
        type = "internal/cpu";
        interval = 3;
        format-prefix = "CPU ";
        format-prefix-foreground = config.stylix.base16Scheme.base0D;
        label = "%percentage:2%%";
      };
      "module/cpu-temp" = {
        type = "custom/script";
        exec = "~/.config/polybar/temperature.sh";
        interval = 3;
      };

      "module/gpu" = {
        type = "custom/script";
        exec = "~/.config/polybar/nvidia.sh";
        interval = 3;
      };
      # "network-base" = {
      # type = "internal/network";
      # interval = 5;
      # format-connected = "<label-connected>";
      # format-disconnected = "<label-disconnected>";
      # label-disconnected = "%{F#F0C674}%ifname%%{F#707880} disconnected";
      # };
      # "module/wlan" = {
      # "inherit" = "network-base";
      # interface-type = "wireless";
      # label-connected = "%{F#F0C674}%ifname%%{F-} %essid% %local_ip%";
      # };
      #"module/eth" = {
      #  "inherit" = "network-base";
      #  interface-type = "wired";
      #  label-connected = "%{F#F0C674}%ifname%%{F-} %local_ip%";
      #};
      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = "%d %b %l:%M %p";
        date-alt = "%Y-%m-%d %H:%M:%S";
        label = "%date%";
        label-foreground = config.stylix.base16Scheme.base06;
        # format-background = colors.background;
      };
      "module/tray" = {
        type = "internal/tray";

        format-margin = "8px";
        tray-spacing = "8px";
      };
      "settings" = {
        screenchange-reload = true;
        pseudo-transparency = false;
      };
    };
  };
}
