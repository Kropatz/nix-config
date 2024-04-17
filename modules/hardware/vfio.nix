{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.custom.hardware.vfio;
in
{
  options.custom.hardware.vfio = {
    enable = mkEnableOption "Enables vfio";
  };
  
  config = mkIf (cfg.enable && config.virtualisation.libvirtd.enable) {
    boot.kernelParams = [ "amd_iommu=on" ];
  };
}
