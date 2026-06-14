{ config, lib, ... }:
with lib;
let
  cfg = config.custom.hardware.scheduler;
in
{
  options.custom.hardware.scheduler = {
    enable = mkEnableOption "Enables scheduler";
  };

}
