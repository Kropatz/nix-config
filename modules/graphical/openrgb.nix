{config, lib,  pkgs, ...}:
with lib;
let
  cfg = config.custom.graphical.openrgb;
in
{
  options.custom.graphical.openrgb = {
    enable = mkEnableOption "Enables openrgb";
  };
  
  config = mkIf cfg.enable {
    services.hardware.openrgb.enable = true;
    services.hardware.openrgb.package = pkgs.openrgb-with-all-plugins;
  };
}
