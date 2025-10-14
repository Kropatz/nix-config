{ config, pkgs, inputs, lib, ... }:
with lib;
let
  cfg = config.custom.graphical.code;
in
{
  options.custom.graphical.code = {
    enable = mkEnableOption "Enables code";
    rider = mkEnableOption "Enables Rider";
    clion = mkEnableOption "Enables Clion";
  };

  config = mkIf cfg.enable {
    documentation.dev.enable = true;
    environment.systemPackages = with pkgs; [
      man-pages
      jetbrains.idea-ultimate
      typescript
      insomnia
      nodejs_22 # needed for tabby extension
      python3
      gcc
    ] ++ lib.optionals cfg.rider [
      pkgs.jetbrains.rider
    ] ++ lib.optionals cfg.clion [
      pkgs.jetbrains.clion
    ];

    #environment.sessionVariables = {
    #  DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";
    #};
  };
}

