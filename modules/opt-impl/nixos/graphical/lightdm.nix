{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.lightdm;
in
{

  config = lib.mkIf cfg.enable {
    services.xserver.displayManager = {
      lightdm.enable = true;
      lightdm.greeters.slick.enable = true;
    };
  };
}
