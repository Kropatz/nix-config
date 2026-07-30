{ lib, ... }:
{
  options.custom.networking = {
    networkmanager.enable = lib.mkEnableOption "Enables networkmanager";
  };
}
