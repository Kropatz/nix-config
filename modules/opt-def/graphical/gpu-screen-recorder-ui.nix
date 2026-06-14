{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.graphical.gpu-screen-recorder-ui;
  package = cfg.package.override {
    inherit (config.security) wrapperDir;
  };
in
{
  options = {
    custom.graphical.gpu-screen-recorder-ui = {
      package = lib.mkPackageOption pkgs "gpu-screen-recorder-ui" { };

      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to install gpu-screen-recorder-ui and generate setcap
          wrappers for global hotkeys.
        '';
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ js6pak ];
}
