{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "tuigreet";
  cfg = config.custom.graphical.${name};
in
{

  options.custom.graphical.${name} = {
    enable = lib.mkEnableOption "Enables tuigreet";
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
          user = "greeter";
        };
      };
    };
  };
}
