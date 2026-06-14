{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "ssh";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables ssh";
  };
}
