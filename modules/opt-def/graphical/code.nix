{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.code;
in
{
  options.custom.graphical.code = {
    enable = mkEnableOption "Enables code";
    rider = mkEnableOption "Enables Rider";
    clion = mkEnableOption "Enables Clion";
  };

}
