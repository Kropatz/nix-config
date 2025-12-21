{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.obs;
in
{
  options.custom.graphical.obs = {
    enable = mkEnableOption "Enables obs";
  };

  config = mkIf cfg.enable {
    # borked in unstable branch
    #boot = {
    #  kernelModules = ["v4l2loopback"]; # Autostart kernel modules on boot
    #  extraModulePackages = with config.boot.kernelPackages; [v4l2loopback]; # loopback module to make OBS virtual camera work
    #};

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
      ];
      enableVirtualCamera = true;
    };
  };
}
