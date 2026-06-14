{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.caldav;
in
{
  options.custom.services.caldav = {
    enable = lib.mkEnableOption "Enables caldav server";
  };
}
