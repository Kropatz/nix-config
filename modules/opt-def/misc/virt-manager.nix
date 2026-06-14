{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.virt-manager;
in
{
  options.custom.virt-manager = {
    enable = mkEnableOption "Enables virt-manager";
  };

}
