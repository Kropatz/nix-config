{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.awesome;
in
{
  options.custom.graphical.awesome = {
    enable = lib.mkEnableOption "Enables awesome";
  };
}
