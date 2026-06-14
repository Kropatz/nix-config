{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.hardware.wooting;
in
{
  options.custom.hardware.wooting = {
    enable = mkEnableOption "Enable wooting hardware support";
  };
}
