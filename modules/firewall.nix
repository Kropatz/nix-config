{ config, pkgs, lib, inputs, vars, ... }:
let
  allowedUDPPortRanges = vars.udpRanges;
in
{
  networking.firewall.allowedUDPPortRanges = allowedUDPPortRanges;
}
