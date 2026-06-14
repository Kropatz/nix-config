{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.gitea-runner;
in
{
  options.custom.services.gitea-runner = {
    enable = lib.mkEnableOption "Enables gitea-runner service.";
    workDir = lib.mkOption {
      type = lib.types.str;
      default = "/1tbssd/gitea-actions-runner";
      description = "Directory for gitea runner.";
    };
  };
}
