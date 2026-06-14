{ pkgs, lib, ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = lib.mkForce [ pkgs.networkmanager-openvpn ];
}
