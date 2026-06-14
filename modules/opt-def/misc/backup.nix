{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.misc.backup;
in
{
  options.custom.misc.backup = {
    enable = mkEnableOption "Enables backup";
    small = lib.mkOption {
      type = types.listOf types.str;
      description = "paths to include in the small backup";
    };
    medium = lib.mkOption {
      type = types.listOf types.str;
      default = cfg.small;
      description = "paths to include in the medium backup";
    };
    large = lib.mkOption {
      type = types.listOf types.str;
      default = cfg.small // cfg.medium;
      description = "paths to include in the large backup";
    };
    excludePaths = lib.mkOption {
      type = types.listOf types.str;
      default = [
        "**/Cache"
        "**/.cache"
        "**/__pycache__"
        "**/node_modules"
        "**/venv"
        "*.o"
        "*.out"
      ];
      description = "paths to exclude from the backup";
    };
    excludePathsRemote = lib.mkOption {
      type = types.listOf types.str;
      default = cfg.excludePaths ++ [ "**/dont_remotebackup" ];
      description = "paths to exclude from the remote backup";
    };
  };
}
