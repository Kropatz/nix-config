{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.custom.hardware.vfio;
in
{
  options.custom.hardware.vfio = {
    enable = mkEnableOption "Enables vfio";
    stub_pci = mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "List of PCI devices to stub with vfio-pci";
    };
  };

}
