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

  config = lib.mkIf cfg.enable {
    programs.gpu-screen-recorder.enable = lib.mkDefault true;

    environment.systemPackages = [ package pkgs.gpu-screen-recorder-notification ];

    security.wrappers."gsr-global-hotkeys" = {
      owner = "root";
      group = "root";
      capabilities = "cap_setuid+ep";
      source = lib.getExe' package "gsr-global-hotkeys";
    };
  };

  meta.maintainers = with lib.maintainers; [ js6pak ];
}
