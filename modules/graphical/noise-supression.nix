{config, pkgs, lib, ...}:
let
    cfg = config.custom.graphical.noise-supression;
in
{
    options.custom.graphical.noise-supression = {
        enable = lib.mkEnableOption "Enables noise-supression";
    };
    
    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          #easyeffects #rust build broken atm
        ];
    };
}
