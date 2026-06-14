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

  config = mkIf (cfg.enable && config.virtualisation.libvirtd.enable) {
    boot = {
      kernelModules = [
        "vfio"
        "vfio_iommu_type1"
        "vfio_pci"
      ];
      kernelParams = [
        "amd_iommu=on"
        "iommu=pt"
      ]
      ++ (if cfg.stub_pci != [ ] then [ "vfio-pci.ids=${concatStringsSep "," cfg.stub_pci}" ] else [ ]);
      blacklistedKernelModules = [
        "nouveau"
        "nvidia"
        "nvidiafb"
        "nvidia-drm"
        "nvidia-uvm"
        "nvidia-modeset"
      ];
    };
  };
}
