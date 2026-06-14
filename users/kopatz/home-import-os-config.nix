{
  osConfig,
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ../../modules/opt-def/default.nix
    ../../modules/opt-def/graphical/stylix.nix
  ];

  custom = osConfig.custom;
}
