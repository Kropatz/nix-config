{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.xfce;
in
{
  options.custom.graphical.xfce = {
    enable = mkEnableOption "Enables xfce";
  };

}
