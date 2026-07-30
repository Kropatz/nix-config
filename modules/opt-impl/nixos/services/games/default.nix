{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.services;
in
{
  config = lib.mkIf cfg.terraria.enable {
    services.terraria = {
      enable = true;
      openFirewall = true;
      password = "seas";
      dataDir = cfg.terraria.path;
    };
  };
}
