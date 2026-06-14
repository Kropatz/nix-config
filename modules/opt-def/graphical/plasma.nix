{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.plasma;
in
{
  options.custom.graphical.plasma = {
    enable = mkEnableOption "Enables plasma";
  };

}
