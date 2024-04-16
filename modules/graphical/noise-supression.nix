{config, lib, pkgs, ...}:
with lib;
let
    cfg = config.kop.graphical.noise-supression;
in
{
    options.kop.graphical.noise-supression = {
        enable = mkEnableOption "Enables noise-supression";
    };
    
    config = mkIf cfg.enable {
        programs.noisetorch.enable = true;
        environment.systemPackages = [
            pkgs.easyeffects
        ];
    };
}
