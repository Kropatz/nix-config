{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.basics;
in
{
  options.custom.graphical.basics = {
    enable = mkEnableOption "Enables basics";
  };

}
