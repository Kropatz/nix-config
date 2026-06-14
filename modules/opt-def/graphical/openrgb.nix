{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.openrgb;
in
{
  options.custom.graphical.openrgb = {
    enable = mkEnableOption "Enables openrgb";
  };

}
