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
      jetbrains.idea-ultimate
      #jetbrains.rider
      typescript
      #jetbrains.clion
      insomnia
      nodejs_22 # needed for tabby extension
      python3
      gcc
    ];

    #environment.sessionVariables = {
    #  DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";
    #};
  };
}

