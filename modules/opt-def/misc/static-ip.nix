{ config, lib, ... }:
with lib;
let
  cfg = config.custom.static-ip;
in
{
  options.custom.static-ip = {
    enable = mkEnableOption "Enables static-ip";
    ip = lib.mkOption {
      type = types.str;
      description = "ipv4 address";
    };
    dns = lib.mkOption {
      type = types.str;
      description = "ip of the dns server";
    };
    interface = lib.mkOption {
      type = types.str;
      description = "interface to apply the change to";
    };
    renameInterface = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Rename the interface to eth0.";
    };
    gateway = lib.mkOption {
      type = types.str;
      default = "192.168.0.1";
      description = "Default gateway";
    };
  };
}
