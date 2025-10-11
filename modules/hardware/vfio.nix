{ pkgs, lib, config, ... }:
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

  config = mkIf (cfg.enable && config.virtualisation.libvirtd.enable) {
    boot = {
      kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" ];
      kernelParams = [ "amd_iommu=on" "iommu=pt" ] ++ (if cfg.stub_pci != [] then [ "vfio-pci.ids=${concatStringsSep "," cfg.stub_pci}" ] else []);
      blacklistedKernelModules = [ "nouveau" "nvidia" "nvidiafb" "nvidia-drm" "nvidia-uvm" "nvidia-modeset" ];
    };
  };
}
