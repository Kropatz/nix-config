{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.xfce;
in
{

  config = mkIf cfg.enable {
    services.xserver = {
      xkb.layout = config.mainUser.layout;
      xkb.variant = config.mainUser.variant;
      enable = true;
      desktopManager.xfce.enable = true;
    };
  };
}
