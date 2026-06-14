{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.wayvnc;
in
{
  options.custom.graphical.wayvnc = {
    enable = mkEnableOption "Enables wayvnc";
  };

}
