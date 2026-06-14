{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.wireguard;
in
{
  options.custom.services.wireguard = {
    enable = mkEnableOption "Enables wireguard";
    ip = lib.mkOption {
      default = "192.168.2.1";
      type = types.str;
      description = "ipv4 address";
    };
    secretFile = mkOption {
      type = types.path;
      default = ../../secrets/wireguard-private.age;
      description = "agenix secret file for wireguard";
    };
    externalInterface = mkOption {
      type = types.str;
      default = "eth0";
      description = "external interface";
    };
  };
}
