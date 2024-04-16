{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.kop.hardware.vfio;
in
{
  options.kop.hardware.vfio = {
    enable = mkEnableOption "Enables vfio";
  };
  
  config = mkIf cfg.enable {
    config = lib.mkIf config.virtualisation.libvirtd.enable {
      boot.kernelParams = [ "amd_iommu=on" ];
    };
  };
}
