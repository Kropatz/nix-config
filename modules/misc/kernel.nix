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
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
