{lib,  config, pkgs, inputs, ... }:
with lib;
let
  cfg = config.kop.graphical.emulators;
in
{
  options.kop.graphical.emulators = {
    enable = mkEnableOption "Enables emulators";
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      snes9x
    ];
  };
}
