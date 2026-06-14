{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.kavita-gitea-runner;
in
{
  options.custom.services.kavita-gitea-runner = {
    enable = mkEnableOption "Enables kavita runner";
    dir = mkOption {
      default = "/data/shares/exposedvm/kavita";
      type = types.path;
      description = "data path";
    };
  };
}
