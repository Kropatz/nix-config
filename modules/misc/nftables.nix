{ config, lib, ... }:
with lib;
let
  cfg = config.custom.nftables;
in
{
  options.custom.nftables = {
    enable = mkEnableOption "Enables nftables";
  };

  config = mkIf cfg.enable {
    networking.nftables.enable = true;
  };
}
