{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "qylock";
  cfg = config.custom.graphical.${name};
in
{

  config = lib.mkIf cfg.enable {
    security.pam.services.qylock = { };
  };
}
