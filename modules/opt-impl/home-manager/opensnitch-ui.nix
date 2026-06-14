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
  config = lib.mkIf cfg.enable { services.opensnitch-ui.enable = true; };
}
