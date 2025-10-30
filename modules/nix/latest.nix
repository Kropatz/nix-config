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
  options.custom.nix = {
    useLatest = mkEnableOption "Use latest nix versions";
  };

  config = mkIf cfg.useLatest {
    nix.package = pkgs.nixVersions.latest;
  };
}
