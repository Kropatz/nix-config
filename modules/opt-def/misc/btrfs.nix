{ config, lib, ... }:
with lib;
let
  cfg = config.custom.misc.btrfs;
in
{
  options.custom.misc.btrfs = {
    enable = mkEnableOption "Enables btrfs scrubbing";
  };

}
