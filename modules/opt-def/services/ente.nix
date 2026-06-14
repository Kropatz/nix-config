{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.ente;
in
{
  options.custom.services.ente = {
    enable = mkEnableOption "Enables ente";
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/ente";
      description = "Directory to store uploaded files";
    };
  };
}
