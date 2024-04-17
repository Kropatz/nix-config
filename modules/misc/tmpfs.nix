{config, lib, ...}:
with lib;
let
    cfg = config.custom.tmpfs;
in
{
    options.custom.tmpfs = {
        enable = mkEnableOption "Enables tmpfs";
    };
    
    config = mkIf cfg.enable {
        boot.tmp.useTmpfs = true;
    };
}

