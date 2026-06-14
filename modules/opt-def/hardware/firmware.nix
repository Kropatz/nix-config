{ config, lib, ... }:
with lib;
let
  cfg = config.custom.hardware.firmware;
in
{
  options.custom.hardware.firmware = {
    enable = mkEnableOption "Enables firmware";
  };

}
