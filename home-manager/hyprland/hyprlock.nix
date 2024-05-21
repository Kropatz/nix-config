{ config, osConfig, pkgs, inputs, lib, ... }:
with lib;
let
    cfg = osConfig.custom.graphical.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    programs.hyprlock.enable = true;
    programs.hyprlock.settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "/synced/default/dinge/Bg/yuyukowallpaper1809.png";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      # TIME
      #label = {
      #    monitor = "";
      #    text = "cmd[update:30000] echo \"$(date +\"%R\")\"";
      #    color = "${config.colorScheme.colors.base05}";
      #    #font_size = 90;
      #    #font_family = "$font";
      #    position = "-130, -100";
      #    halign = "right";
      #    valign = "top";
      #    shadow_passes = 2;
      #};
      #
      ## DATE 
      #label = {
      #    monitor = "";
      #    text = "cmd[update:43200000] echo \"$(date +\"%A, %d %B %Y\")\"";
      #    color = "${config.colorScheme.colors.base05}";
      #    #font_size = "25";
      #    #font_family = "$font";
      #    position = "-130, -250";
      #    halign = "right";
      #    valign = "top";
      #    shadow_passes = 2;
      #};
      input-field = [
        {
          size = "400, 100";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "Password...";
          shadow_passes = 2;
        }
      ];
    };
    services.hypridle.enable = true;
    services.hypridle.settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };

      listener = [
        {
          timeout = 900;
          on-timeout = "hyprlock";
        }
        {
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

}
