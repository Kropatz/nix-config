{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.ime;
in
{
  options.custom.graphical.ime = {
    enable = mkEnableOption "Enables ime";
  };

}
