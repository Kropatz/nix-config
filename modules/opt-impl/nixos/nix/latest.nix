{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.nix;
in
{

  config = mkIf cfg.useLatest {
    nix.package = pkgs.nixVersions.latest;
  };
}
