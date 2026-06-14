{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.fileshelter;
in
{
  options.custom.services.fileshelter = {
    enable = mkEnableOption "Enables fileshelter";
    uid = mkOption {
      default = 20000;
      description = "uid of the fileshelter user";
    };
  };
}
