{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.hardware.android;
in
{
  options.custom.hardware.android = {
    enable = lib.mkEnableOption "Enables android phone support";
  };

}
