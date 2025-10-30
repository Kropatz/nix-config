{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.nixvimPlugins;
in
{
  options.custom.nixvimPlugins = mkEnableOption "Enables nixvim plugins";
}
