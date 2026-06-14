{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.kop-monitor;
in
{
  options.custom.services.kop-monitor = {
    enable = mkEnableOption "Enables monitor";
  };
}
