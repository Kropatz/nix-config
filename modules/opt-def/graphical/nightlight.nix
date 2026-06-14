{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.graphical.nightlight;
in
{
  options.custom.graphical.nightlight = {
    enable = lib.mkEnableOption "Enables nightlight";
  };

}
