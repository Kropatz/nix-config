{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.shared;
in
{
  options.custom.graphical.shared = {
    enable = mkEnableOption "Enables shared";
  };

}
