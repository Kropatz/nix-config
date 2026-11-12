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
  config = lib.mkIf cfg.enable {
    programs.gpu-screen-recorder.enable = true;
    programs.gpu-screen-recorder.ui.enable = true;
  };
}
