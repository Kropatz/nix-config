{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.emulators;
in
{
  options.custom.graphical.emulators = {
    enable = mkEnableOption "Enables emulators";
  };

}
