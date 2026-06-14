{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "qbittorrent";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables qbittorrent";
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/seed/qb";
      description = "Directory to store uploaded files";
    };
  };

}
