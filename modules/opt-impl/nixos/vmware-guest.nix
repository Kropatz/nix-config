{ config, pkgs, ... }:
{
  ## shared clipboard
  virtualisation.vmware.guest.enable = true;
  environment.systemPackages = with pkgs; [
    open-vm-tools
  ];
}
