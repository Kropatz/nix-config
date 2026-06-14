{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.cli-tools;
in
{
  options.custom.cli-tools = {
    enable = mkEnableOption "Enables cli-tools";
    saveSpace = mkEnableOption "Saves disk space by skipping some packages.";
  };
}
