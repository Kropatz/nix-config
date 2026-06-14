{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.step-ca;
in
{
  options.custom.services.step-ca = {
    enable = mkEnableOption "Enables step-ca";
  };
}
