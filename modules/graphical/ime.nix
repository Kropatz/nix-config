{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical.ime;
in
{
  options.custom.graphical.ime = {
    enable = mkEnableOption "Enables ime";
  };
  
  config = mkIf cfg.enable {
    i18n.inputMethod.type = "fcitx5"; #deprecated
    ## new
    #i18n.enable = true;
    #i18n.inputMethod.type = "fcitx5";
    i18n.inputMethod.fcitx5.addons = [ pkgs.fcitx5-mozc ];
  };
}
