{ lib, ... }:
{
  options.custom.services = {
    terraria = {
      enable = lib.mkEnableOption "Enables terraria server";
      path = lib.mkOption {
        type = with lib.types; str;
        default = "/data/servers/terraria";
        description = "Base path for terraria server";
      };
    };
  };
}
