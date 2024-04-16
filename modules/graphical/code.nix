{ config, pkgs, inputs, lib, ... }:
with lib;
let
  cfg = config.kop.graphical.code;
in
{
  options.kop.graphical.code = {
    enable = mkEnableOption "Enables code";
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kate
      jetbrains.idea-ultimate
      insomnia
    ];
  
    #environment.sessionVariables = {
    #  DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";
    #};
  };
}

