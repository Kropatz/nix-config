{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.github-runner;
in
{
  options.custom.services.github-runner = {
    enable = lib.mkEnableOption "Enables github-runner service.";
  };
}
