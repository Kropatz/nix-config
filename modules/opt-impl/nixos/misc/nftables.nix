{ config, lib, ... }:
with lib;
let
  cfg = config.custom.nftables;
in
{

  config = mkIf cfg.enable {
    networking.nftables.enable = true;
  };
}
