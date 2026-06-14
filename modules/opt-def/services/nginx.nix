{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.nginx;
in
{
  options.custom.services.nginx = {
    enable = mkEnableOption "Enables nginx";
    https = mkOption {
      type = types.bool;
      default = true;
      description = "Should it use https?";
    };
    dav = mkEnableOption "Enables WebDAV support on /hdd/nginx";
  };
}
