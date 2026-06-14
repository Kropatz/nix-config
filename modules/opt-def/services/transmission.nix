{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "transmission";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables transmission";
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/seed";
      description = "Directory to store uploaded files";
    };
  };

}
