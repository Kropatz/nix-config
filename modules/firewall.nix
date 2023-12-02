{ config, pkgs, lib, inputs, vars, ... }:
let
  allowedUDPPortRanges = vars.udpRanges;
in
{
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPortRanges = allowedUDPPortRanges;
}
