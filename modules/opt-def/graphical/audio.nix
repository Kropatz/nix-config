{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.audio;
in
{
  options.custom.graphical.audio = {
    enable = mkEnableOption "Enables audio";
  };

}
