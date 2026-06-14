{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.hardware.tablet;
in
{
  options.custom.hardware.tablet = {
    enable = mkEnableOption "Enables tablet";
  };

}
