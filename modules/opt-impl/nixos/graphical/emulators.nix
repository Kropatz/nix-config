{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.emulators;
in
{

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      snes9x
    ];
  };
}
