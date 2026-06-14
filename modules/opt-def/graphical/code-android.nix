{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.code.android;
in
{
  options.custom.graphical.code.android = {
    enable = mkEnableOption "Enables code";
  };

}
