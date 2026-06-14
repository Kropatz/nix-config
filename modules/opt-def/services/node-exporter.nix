{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "node-exporter";
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables node-exporter";
  };

}
