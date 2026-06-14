{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.lxqt;
in
{
  options.custom.graphical.lxqt = {
    enable = mkEnableOption "Enables lxqt";
  };

}
