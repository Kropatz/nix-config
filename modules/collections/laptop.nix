{pkgs, config, ...}:
{
  kop = {
    cli-tools.enable = true;
    tmpfs.enable = true;
    wireshark.enable = true;
    virt-manager.enable = true;
    hardware = {
      firmware.enable = true;
      ssd.enable = true;
    };
  };
}
