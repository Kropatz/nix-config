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
  options.custom.services.terraria = {
    enable = lib.mkEnableOption "Enables terraria server";
    path = lib.mkOption {
      type = with lib.types; str;
      default = "/data/servers/terraria";
      description = "Base path for terraria server";
    };
  };
  config = lib.mkIf cfg.enable {
    services.terraria = {
      enable = true;
      openFirewall = true;
      password = "seas";
      dataDir = cfg.path;
    };
  };
}
