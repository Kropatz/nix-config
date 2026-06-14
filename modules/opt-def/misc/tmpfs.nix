{ config, lib, ... }:
with lib;
let
  cfg = config.custom.tmpfs;
in
{
  options.custom.tmpfs = {
    enable = mkEnableOption "Enables tmpfs";
  };

}
