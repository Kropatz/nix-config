{ config, lib, ... }:
with lib;
let
  cfg = config.custom.hardware.scheduler;
in
{

  config = mkIf cfg.enable {
    services.system76-scheduler = {
      enable = true;
    };

    hardware.system76.enableAll = true;
  };
}
