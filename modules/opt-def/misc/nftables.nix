{ config, lib, ... }:
with lib;
let
  cfg = config.custom.nftables;
in
{
  options.custom.nftables = {
    enable = mkEnableOption "Enables nftables";
  };

}
