{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.terraria;
in
{
  config = lib.mkIf cfg.enable {
    services.terraria = {
      enable = true;
      openFirewall = true;
      password = "seas";
      dataDir = cfg.path;
    };
  };
}
