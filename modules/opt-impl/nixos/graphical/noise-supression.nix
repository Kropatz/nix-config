{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.noise-supression;
in
{

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      easyeffects
    ];
  };
}
