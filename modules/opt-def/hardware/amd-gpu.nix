{
  lib,
  config,
  pkgs,
  inputs,
  pkgsVersion,
  ...
}:
let
  cfg = config.custom.hardware.amd-gpu;
in
{
  options.custom.hardware.amd-gpu = {
    enable = lib.mkEnableOption "Enables amd gpus";
    overdrive = lib.mkEnableOption "Enables overdrive";
    rocm.enable = lib.mkEnableOption "Enables rocm";
  };

}
