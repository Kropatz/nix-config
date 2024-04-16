{config, lib,  pkgs, ...}:
with lib;
let
  cfg = config.kop.graphical.openrgb;
in
{
  options.kop.graphical.openrgb = {
    enable = mkEnableOption "Enables openrgb";
  };
  
  config = mkIf cfg.enable {
    services.hardware.openrgb.enable = true;
    services.hardware.openrgb.package = pkgs.openrgb-with-all-plugins;
  };
}
