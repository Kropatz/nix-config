{ pkgs, ... }: {
  services.resolved.enable = true;
  programs.openvpn3.enable = true;
  #mdns resolves to ipv6 address idk why
  #networking.firewall.allowedUDPPorts = [ 5353 ];
}
