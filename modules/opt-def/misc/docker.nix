{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.misc.docker;
in
{
  options.custom.misc.docker = {
    enable = mkEnableOption "Enables docker";
  };
}
