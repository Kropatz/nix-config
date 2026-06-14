{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  cfg = config.custom.graphical.cosmic;
in
{
  options.custom.graphical.cosmic = {
    enable = lib.mkEnableOption "Enables cosmic";
  };

}
