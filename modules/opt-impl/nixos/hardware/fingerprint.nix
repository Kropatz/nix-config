{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.hardware.fingerprint;
in
{

  config = lib.mkIf cfg.enable {

    services.fprintd = {
      enable = true;
    };
  };
}
