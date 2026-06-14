{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "networkmanager";
  cfg = config.custom.networking.${name};
in
{
  options.custom.networking.${name} = {
    enable = lib.mkEnableOption "Enables networkmanager";
  };
}
