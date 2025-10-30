{
  osConfig,
  pkgs,
  lib,
  ...
}:

let
  cfg = osConfig.custom.graphical.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.file.".config/hypr/hyprshade.toml".source = ../../.config/hypr/hyprshade.toml;
    wayland.windowManager.hyprland.settings.exec-once = [ "${pkgs.hyprshade}/bin/hyprshade auto" ];
    systemd.user = {

      services.hyprshade = {
        Install.WantedBy = [ "graphical-session.target" ];

        Unit = {
          ConditionEnvironment = "HYPRLAND_INSTANCE_SIGNATURE";
          Description = "Apply screen filter";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.hyprshade}/bin/hyprshade auto";
        };
      };

      timers.hyprshade = {

        Install.WantedBy = [ "timers.target" ];

        Unit = {
          Description = "Apply screen filter on schedule";
        };

        Timer.OnCalendar = [
          "*-*-* 06:00:00"
          "*-*-* 19:00:00"
        ];
      };
    };
  };
}
