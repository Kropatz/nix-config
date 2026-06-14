{
  pkgs,
  config,
  lib,
  ...
}:
# idk, dont need this
with lib;
let
  cfg = config.custom.services.kubernetes;
in
{
  options.custom.services.kubernetes = {
    enable = mkEnableOption "Enables kubernetes";
  };
}
