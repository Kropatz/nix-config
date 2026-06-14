{ config, lib, ... }:
with lib;
let
  cfg = config.custom.hardware.firmware;
in
{

  config = mkIf cfg.enable {
    services.fwupd.enable = true;
  };
}
