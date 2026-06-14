{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.hardware.tpm;
in
{
  options.custom.hardware.tpm = {
    enable = mkEnableOption "Enables tpm";
  };

}
