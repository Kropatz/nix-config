{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "smartd-exporter";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables smartd monitoring";
  };
}
