
{ config, pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    snes9x
  ];
}
