{ config, pkgs, inputs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    kate
    jetbrains.idea-ultimate
    insomnia
  ];

  #environment.sessionVariables = {
  #  DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";
  #};


}
