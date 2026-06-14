{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "netbird";
  cfg = config.custom.services.${name};
  baseDir = "/1tbssd/netbird";
  domain = "netbird.kopatz.dev";
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables netbird";
    domain = lib.mkOption {
      type = lib.types.str;
      default = domain;
      description = "Domain for the NetBird management API (e.g. for dashboard and CLI access).";
    };
    baseDir = lib.mkOption {
      type = lib.types.str;
      default = baseDir;
      description = "Base directory for NetBird state and config (e.g. /var/lib/netbird).";
    };
  };

}
