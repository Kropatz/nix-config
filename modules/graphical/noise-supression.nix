{config, lib, pkgs, ...}:
with lib;
let
    cfg = config.custom.graphical.noise-supression;
in
{
    options.custom.graphical.noise-supression = {
        enable = mkEnableOption "Enables noise-supression";
    };
    
    config = mkIf cfg.enable {
        programs.noisetorch.enable = true;
        environment.systemPackages = [
            pkgs.easyeffects
        ];
    };
}
