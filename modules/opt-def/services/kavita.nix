{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.kavita;
in
{
  options.custom.services.kavita = {
    enable = mkEnableOption "Enables kavita";
    https = mkOption {
      type = types.bool;
      default = true;
      description = "Should it use https?";
    };
    autoDownload = mkOption {
      type = types.bool;
      default = true;
      description = "Should it auto download?";
    };
    dir = mkOption {
      default = "/data/kavita";
      type = types.path;
      description = "data path";
    };
    isTest = mkEnableOption "Is this a test vm?";
  };
}
