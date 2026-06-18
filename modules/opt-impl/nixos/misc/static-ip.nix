{ config, lib, ... }:
with lib;
let
  cfg = config.custom.static-ip;
in
{
  config =
    let
      fallback = "1.1.1.1";
    in
    mkIf cfg.enable {
      networking = {
        defaultGateway = {
          address = cfg.gateway;
          interface = if cfg.renameInterface then "eth0" else cfg.interface;
        };
        useDHCP = false;
        nameservers = [ cfg.dns ] ++ lib.lists.optionals (!config.services.resolved.enable) [ fallback ];
        interfaces = {
          ${cfg.interface} = {
            name = if cfg.renameInterface then "eth0" else cfg.interface;
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
        settings = {
          Resolve = {
            LLMR = "false";
            FallbackDNS = [ "1.1.1.1" ];
          };
        };
      };
    };
}
