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
    ## Enable blue-light filter
    #hyprctl hyprsunset temperature 2500
    ## Disable blue-light filter
    #hyprctl hyprsunset identity
    #
    ## Set gamma to 50%
    #hyprctl hyprsunset gamma 50
    ## Increase gamma by 10%
    #hyprctl hyprsunset gamma +10
    #
    ## Reset config to current profile
    #hyprctl hyprsunset reset
    ## Reset value to current profile
    #hyprctl hyprsunset reset temperature
    #hyprctl hyprsunset reset gamma
    #hyprctl hyprsunset reset identity
    #
    ## Print current profile
    #hyprctl hyprsunset profile
    services.hyprsunset = {
      enable = true;
      settings = {
        max-gamma = 150;

        profile = [
          {
            time = "7:30";
            identity = true;
          }
          {
            time = "19:00";
            temperature = 3000;
            gamma = 0.8;
          }
        ];
      };
    };
  };
}
