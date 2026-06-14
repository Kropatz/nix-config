{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.custom.misc.firejail;
in
{

  config = lib.mkIf cfg.enable { programs.firejail.enable = true; };
}
