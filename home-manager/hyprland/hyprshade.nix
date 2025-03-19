{ osConfig, pkgs, lib, ... }:

let cfg = osConfig.custom.graphical.hyprland;
in {
  config = lib.mkIf cfg.enable {
    home.activation.hyprshade = {
      after = [ "writeBoundary" ];
      before = [ ];
      data = ''
        ${pkgs.hyprshade}/bin/hyprshade install
        ${pkgs.systemd}/bin/systemctl --user enable --now hyprshade.timer
      '';
    };
    home.file.".config/hypr/hyprshade.toml".source = ../../.config/hypr/hyprshade.toml;
    wayland.windowManager.hyprland.settings.exec-once = [ "${pkgs.hyprshade}/bin/hyprshade auto" ];
  };
}
