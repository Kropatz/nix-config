{ config, lib, ... }:
with lib;
let
  cfg = config.custom.hardware.ssd;
in
{

  config = mkIf cfg.enable {
    services.fstrim.enable = true;
  };
}
