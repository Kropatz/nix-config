{config, lib, ...}:
with lib;
let
  cfg = config.kop.hardware.firmware;
in
{
  options.kop.hardware.firmware = {
    enable = mkEnableOption "Enables firmware";
  };
  
  config = mkIf cfg.enable {
    services.fwupd.enable = true;
  };
}

