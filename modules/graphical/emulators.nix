{lib,  config, pkgs, inputs, ... }:
with lib;
let
  cfg = config.custom.graphical.emulators;
in
{
  options.custom.graphical.emulators = {
    enable = mkEnableOption "Enables emulators";
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      snes9x
    ];
  };
}
