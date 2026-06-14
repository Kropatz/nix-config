{ config, lib, ... }:
with lib;
let
  cfg = config.custom.misc.btrfs;
in
{

  config = mkIf cfg.enable {
    services.btrfs.autoScrub.enable = true;
  };
}
