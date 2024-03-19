{ config, pkgs, ...}:
{
  # borked in unstable branch
  #boot = {
  #  kernelModules = ["v4l2loopback"]; # Autostart kernel modules on boot
  #  extraModulePackages = with config.boot.kernelPackages; [v4l2loopback]; # loopback module to make OBS virtual camera work
  #};

  environment.systemPackages = with pkgs; [
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        obs-pipewire-audio-capture
      ];
    })
  ];
}
