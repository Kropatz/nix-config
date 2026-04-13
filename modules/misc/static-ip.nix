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
    gateway = lib.mkOption {
      type = types.str;
      default = "192.168.0.1";
      description = "Default gateway";
    };
  };
  config =
    let
      fallback = "1.1.1.1";
    in
    mkIf cfg.enable {
      networking = {
        defaultGateway = cfg.gateway;
        useDHCP = false;
        nameservers = [ cfg.dns ] ++ lib.lists.optionals (!config.services.resolved.enable) [ fallback ];
        interfaces = {
          ${cfg.interface} = {
            name = "eth0";
            ipv4.addresses = [
              {
                address = cfg.ip;
                prefixLength = 24;
              }
            ];
          };
        };
      };

      services.resolved = lib.mkIf config.services.resolved.enable {
        llmnr = "false";
        fallbackDns = [ "1.1.1.1" ];
      };
    };
}
