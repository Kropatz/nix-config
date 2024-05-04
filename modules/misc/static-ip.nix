{config, lib, ...}:
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
   };
   config = mkIf cfg.enable {
     networking = {
       defaultGateway = "192.168.0.1";
       useDHCP = false;
       nameservers = [
         cfg.dns
         "1.1.1.1"
       ];
       interfaces = {
         ${cfg.interface} = {
           name = "eth0";
           ipv4.addresses = [{
             address = cfg.ip;
             prefixLength = 24;
           }];
         };
       };
     };
  };
}
