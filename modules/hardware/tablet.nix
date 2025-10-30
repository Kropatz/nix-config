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

  config = mkIf cfg.enable {
    hardware.opentabletdriver.enable = true;
    #hardware.opentabletdriver.package = pkgs.opentabletdriver.overrideAttrs
    #  (old: { patches = old.patches ++ [ ./tablet-patches.diff ]; });
  };
}
