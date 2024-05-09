{ config, pkgs, inputs, lib, ... }:
with lib;
let
  cfg = config.custom.graphical.code;
in
{
  options.custom.graphical.code = {
    enable = mkEnableOption "Enables code";
  };
  
  config = mkIf cfg.enable {
    documentation.dev.enable = true;
    environment.systemPackages = with pkgs; [
      man-pages
      kate
      jetbrains.idea-ultimate
      #jetbrains.clion
      insomnia
      nodejs_22 # needed for tabby extension
    ];
  
    #environment.sessionVariables = {
    #  DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";
    #};
  };
}

