{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.nix.ld;
in
{
  options.custom.nix.ld = {
    enable = mkEnableOption "Enables nix ld";
  };

}
