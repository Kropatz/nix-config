{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "zram";
  cfg = config.custom.misc.${name};
in
{

  config = lib.mkIf cfg.enable {
    zramSwap = {
      enable = true;
    };
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.page-cluster" = 0;
      #"vm.watermark_boost_factor" = 0;
      #"vm.watermark_scale_factor" = 125;
    };
  };
}
