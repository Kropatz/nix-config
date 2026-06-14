{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.acme;
in
{
  options.custom.services.acme = {
    enable = mkEnableOption "Enables acme";
  };
}
