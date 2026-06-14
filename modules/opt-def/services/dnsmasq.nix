{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.dnsmasq;
in
{
  options.custom.services.dnsmasq = {
    enable = mkEnableOption "Enables dnsmaq service";
    server = mkOption { type = types.listOf types.string; };
  };
}
