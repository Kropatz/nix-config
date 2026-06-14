{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "networkmanager";
  cfg = config.custom.networking.${name};
in
{
  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
    networking.networkmanager.plugins = lib.mkForce [ pkgs.networkmanager-openvpn ];
  };
}
