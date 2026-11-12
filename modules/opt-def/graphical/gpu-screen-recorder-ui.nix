{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.graphical.gpu-screen-recorder-ui;
in
{
  options = {
    custom.graphical.gpu-screen-recorder-ui = {

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
}
