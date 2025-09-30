{ pkgs, lib, config, ... }: {
  zramSwap = {
    enable = true;
  };
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
    #"vm.watermark_boost_factor" = 0;
    #"vm.watermark_scale_factor" = 125;
  };
}
