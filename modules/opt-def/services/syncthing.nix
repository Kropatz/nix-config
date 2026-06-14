{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.syncthing;
in
{
  options.custom.services.syncthing = {
    enable = lib.mkEnableOption "Enables syncthing";
    basePath = lib.mkOption {
      type = with lib.types; str;
      default = "/home/${config.mainUser.name}/synced";
      description = "Base path for syncthing data";
    };
  };
}
