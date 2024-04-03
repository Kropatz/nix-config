{ config, pkgs, lib, inputs, vars, ... }:
let
  allowedUDPPortRanges = vars.udpRanges;
in
{
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [ 5000 ];
  networking.firewall.allowedUDPPortRanges = allowedUDPPortRanges;
}
