{ config, lib, ... }:
with lib;
let
  cfg = config.custom.nix.index;
in
{

  config = mkIf cfg.enable {
    programs.command-not-found.enable = false;
    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
