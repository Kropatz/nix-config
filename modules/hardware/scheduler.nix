{config, lib, ...}:
with lib;
let
    cfg = config.kop.hardware.scheduler;
in
{
    options.kop.hardware.scheduler = {
        enable = mkEnableOption "Enables scheduler";
    };
    
    config = mkIf cfg.enable {
        services.system76-scheduler = {
            enable = true;
        };
    
        hardware.system76.enableAll = true;
    };
}

