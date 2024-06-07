{ config, pkgs, lib, ... }:
let cfg = config.custom.hardware.fingerprint;
in {
  options.custom.hardware.fingerprint = {
    enable = lib.mkEnableOption "Enables fingerprint sensor support";
  };

  config = lib.mkIf cfg.enable {

    services.fprintd = {
      enable = true;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-goodix;
      };
    };
  };
}
