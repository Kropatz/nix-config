{config, lib, ...}:
with lib;
let
   cfg = config.kop.nftables;
in
{
   options.kop.nftables = {
      enable = mkEnableOption "Enables nftables";
   };
   
   config = mkIf cfg.enable {
      networking.nftables.enable = true;
   };
}

