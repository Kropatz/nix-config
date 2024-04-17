{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical.gamemode;
in
{
  options.custom.graphical.gamemode = {
    enable = mkEnableOption "Enables gamemode";
  };
  
  config = mkIf cfg.enable {
    programs.gamemode = {
      enable = true;
      settings.custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };
}
