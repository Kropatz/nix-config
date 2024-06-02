{ config, lib, ... }:
let cfg = config.custom.graphical.gnome;
in {
  # doesnt work for me.. nothing changes
  config = lib.mkIf cfg.enable {
    programs.dconf.profiles.user.databases = [{
      lockAll = true;
      settings = with lib.gvariant; {
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          ];
        };
        "org/gnome/desktop/wm/preferences" = {
          resize-with-right-button = true;
        };
        "org/gnome/desktop/sound" = { event-sounds = false; };
        "org/gnome/desktop/peripherals/mouse" = { accel-profile = "flat"; };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
          {
            name = "nautilus";
            command = "nautilus";
            binding = "<Super>e";
          };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" =
          {
            name = "kitty super";
            command = "kitty";
            binding = "<Super>q";
          };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" =
          {
            binding = "<Alt>space";
            command = "rofi -show combi";
            name = "Open Rofi";
          };
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "blur-my-shell@aunetx"
            "trayIconsReloaded@selfmade.pl"
            "Vitals@CoreCoding.com"
            "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
            "dash-to-dock@micxgx.gmail.com"
            "just-perfection-desktop@just-perfection"
            "user-theme@gnome-shell-extensions.gcampax.github.com"
            "apps-menu@gnome-shell-extensions.gcampax.github.com"
          ];
        };
        "org/gnome/mutter" = {
          edge-tiling = true;
          workspaces-only-on-primary = true;
          dynamic-workspaces = false;
        };
        #"org/gnome/desktop/wm/preferences" = {
        #  num-workspaces = 9;
        #  focus-mode = "sloppy";
        #};
        "org/gnome/desktop/wm/keybindings" = {
          #minimize = [ "<Super>comma" ];
          maximize = [ "<Super>f" ];
          #switch-to-workspace-left = [ "<Super>e" ];
          #switch-to-workspace-right = [ "<Super>r" ];
          unmaximize = mkEmptyArray type.string;
          activate-window-menu = mkEmptyArray type.string;
          move-to-monitor-up = mkEmptyArray type.string;
          move-to-monitor-down = mkEmptyArray type.string;
          #move-to-monitor-left = [ "<Super><Shift>e" ];
          #move-to-monitor-right = [ "<Super><Shift>r" ];
          move-to-workspace-down = mkEmptyArray type.string;
          move-to-workspace-up = mkEmptyArray type.string;
          switch-to-workspace-down =
            [ "<Primary><Super>Down" "<Primary><Super>j" ];
          switch-to-workspace-up = [ "<Primary><Super>Up" "<Primary><Super>k" ];
          toggle-maximized = [ "<Super>f" ];
          close = [ "<Alt>F4" ];
          switch-to-workspace-1 = [ "<Super>1" ];
          switch-to-workspace-2 = [ "<Super>2" ];
          switch-to-workspace-3 = [ "<Super>3" ];
          switch-to-workspace-4 = [ "<Super>4" ];
          switch-to-workspace-5 = [ "<Super>5" ];
          switch-to-workspace-6 = [ "<Super>6" ];
          switch-to-workspace-7 = [ "<Super>7" ];
          switch-to-workspace-8 = [ "<Super>8" ];
          switch-to-workspace-9 = [ "<Super>9" ];
          move-to-workspace-1 = [ "<Super><Shift>1" ];
          move-to-workspace-2 = [ "<Super><Shift>2" ];
          move-to-workspace-3 = [ "<Super><Shift>3" ];
          move-to-workspace-4 = [ "<Super><Shift>4" ];
          move-to-workspace-5 = [ "<Super><Shift>5" ];
          move-to-workspace-6 = [ "<Super><Shift>6" ];
          move-to-workspace-7 = [ "<Super><Shift>7" ];
          move-to-workspace-8 = [ "<Super><Shift>8" ];
          move-to-workspace-9 = [ "<Super><Shift>9" ];
        };
        "org/gnome/shell/keybindings" = {
          # Following binds need to be disabled, as their defaults are used for
          # the binds above, and will run into conflicts.
          switch-to-application-1 = mkEmptyArray type.string;
          switch-to-application-2 = mkEmptyArray type.string;
          switch-to-application-3 = mkEmptyArray type.string;
          switch-to-application-4 = mkEmptyArray type.string;
          switch-to-application-5 = mkEmptyArray type.string;
          switch-to-application-6 = mkEmptyArray type.string;
          switch-to-application-7 = mkEmptyArray type.string;
          switch-to-application-8 = mkEmptyArray type.string;
          switch-to-application-9 = mkEmptyArray type.string;
        };
      };
    }];
  };
}
