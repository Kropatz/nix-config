{
  lib,
  inputs,
  config,
  pkgsVersion,
  ...
}:
with lib;
let
  cfg = config.custom.nix.settings;
  cache = "https://cache.nixos.org";
in
{
  options.custom.nix.settings = {
    enable = mkEnableOption "Enables various nix settings";
    optimise = mkOption {
      type = with types; bool;
      default = true;
      description = "Optimise nix store";
    };
  };

}
