{config, lib, ...}:
with lib;
let
    cfg = config.kop.hardware.ssd;
in
{
    options.kop.hardware.ssd = {
        enable = mkEnableOption "Enables fstrim";
    };
    
    config = mkIf cfg.enable {
        services.fstrim.enable = true;
    };
}

