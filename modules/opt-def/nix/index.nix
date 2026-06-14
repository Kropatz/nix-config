{ config, lib, ... }:
with lib;
let
  cfg = config.custom.nix.index;
in
{
  options.custom.nix.index = {
    enable = mkEnableOption "Enables nix index";
  };

}
