{ pkgs, lib, config, ... }:
{
  config = lib.mkIf config.virtualisation.libvirtd.enable {
    boot.kernelParams = [ "amd_iommu=on" ];
  };
}
