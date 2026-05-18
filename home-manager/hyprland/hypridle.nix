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
in
{
  config = lib.mkIf cfg.enable {
    # don't autostart
    systemd.user.services.hypridle.Service.ExecStart = lib.mkForce "${pkgs.coreutils}/bin/true";
    systemd.user.services.hypridle.Service.Restart = lib.mkForce "no";
    services.hypridle.enable = true;
    services.hypridle.settings = {
      general = {
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = if osConfig.custom.graphical.qylock.enable then "pidof .quickshell-wrapped || qylock-lock" else "pidof hyprlock || hyprlock ";
      };

      listener = [
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 900;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1200;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

}
