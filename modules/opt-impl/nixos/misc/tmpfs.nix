{ config, lib, ... }:
with lib;
let
  cfg = config.custom.tmpfs;
in
{

  config = mkIf cfg.enable {
    boot.tmp.useTmpfs = true;
  };
}
