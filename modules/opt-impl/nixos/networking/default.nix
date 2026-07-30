{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.networking;
in
{
  config = lib.mkIf cfg.networkmanager.enable {
    networking.networkmanager.enable = true;
    networking.networkmanager.plugins = lib.mkForce [ pkgs.networkmanager-openvpn ];
  };
}
