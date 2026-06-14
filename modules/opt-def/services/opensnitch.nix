{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.opensnitch;
in
{
  options.custom.services.opensnitch = {
    enable = lib.mkEnableOption "Enables opensnitch";
  };
}
