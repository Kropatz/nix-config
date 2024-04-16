{config, lib, ...}:
with lib;
let
    cfg = config.kop.tmpfs;
in
{
    options.kop.tmpfs = {
        enable = mkEnableOption "Enables tmpfs";
    };
    
    config = mkIf cfg.enable {
        boot.tmp.useTmpfs = true;
    };
}

