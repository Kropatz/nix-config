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

  config = lib.mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
