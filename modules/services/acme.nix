{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.custom.services.acme;
in
{
  options.custom.services.acme = {
    enable = mkEnableOption "Enables acme";
  };
  config = lib.mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = "7265381+Kropatz@users.noreply.github.com";
    };
  };
}
