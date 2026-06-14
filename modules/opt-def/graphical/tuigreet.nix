{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "tuigreet";
  cfg = config.custom.graphical.${name};
in
{

  options.custom.graphical.${name} = {
    enable = lib.mkEnableOption "Enables tuigreet";
  };

}
