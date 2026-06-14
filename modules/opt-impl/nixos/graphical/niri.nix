{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.niri;
in
{

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
    };
    environment.systemPackages = with pkgs; [ xwayland-satellite ];
  };
}
