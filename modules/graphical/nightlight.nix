{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.graphical.nightlight;
in
{
  options.custom.graphical.nightlight = {
    enable = lib.mkEnableOption "Enables nightlight";
  };

  config = lib.mkIf cfg.enable {
    location.latitude = 48.2082;
    location.longitude = 16.3738;
    services.redshift.enable = true;
  };
}
