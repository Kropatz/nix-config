{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "newkernel";
  cfg = config.custom.misc.${name};
in
{

  options.custom.misc.${name} = {
    enable = lib.mkEnableOption "Enables new kernel";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_6_19; # 7.0 seems to have some stutter issues
  };
}
