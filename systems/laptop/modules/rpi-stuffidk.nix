{ pkgs, ... }:
let
  pi_interface = "enp193s0f3u2";
in
{

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  networking.interfaces."${pi_interface}" = {
    ipv4.addresses = [{
      address = "192.168.1.1";
      prefixLength = 24;
    }];
  };
  networking.firewall.allowedUDPPorts = [ 67 68 ];
  services = {
    kea.dhcp4 = {
      enable = true;
      settings = {
        interfaces-config = {
          interfaces = [ pi_interface ];
        };
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };
        authoritative = true;
        valid-lifetime = 8000;
        rebind-timer = 4000;
        renew-timer = 2000;
        subnet4 = [
          {
            id = 1;
            pools = [
              {
                pool = "192.168.1.32 - 192.168.1.254";
              }
            ];
            subnet = "192.168.1.0/24";
          }
        ];
        option-data = [
          {
            name = "domain-name-servers";
            csv-format = true;
            data = "1.1.1.1";
          }
          # {
          #   name = "ntp-servers";
          #   data ="${config.localIP}";
          # }
          {
            name = "routers";
            data = "192.168.1.1";
          }
        ];
      };
    };
  };


}
