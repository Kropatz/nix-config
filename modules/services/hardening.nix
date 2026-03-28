{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.hardening;
in
{
  options.custom.services.hardening = {
    dataMounts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "-/data" "-/1tbssd" "-/hdd" ];
      description = "Paths to set as InaccessiblePaths. Needs to be paired with SystemCallFilter=~@mount and/or CapabilityBoundingSet=~CAP_SYS_ADMIN.";
    };
  };
}
