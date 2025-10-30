{
  pkgs,
  modulesPath,
  config,
  lib,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
  ];

  # use the latest Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  users.users.root.initialHashedPassword = lib.mkForce "$y$j9T$PtiIvvs6UUq2PkyR9egC.0$/o9IIo66NmH8m/rW/DrhzZzY0IfA.FfYbxb6Pa.YPnD";
  users.users.nixos.initialHashedPassword = lib.mkForce "$y$j9T$PtiIvvs6UUq2PkyR9egC.0$/o9IIo66NmH8m/rW/DrhzZzY0IfA.FfYbxb6Pa.YPnD";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  boot.kernelParams = [ "nvidia-drm.fbdev=1" ];
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;
    # Open drivers with gsp stutters in VR - https://github.com/ValveSoftware/SteamVR-for-Linux/issues/631
    gsp.enable = false;
    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;
    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # GSP must be enabled for this to work.
    open = false;
    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;
    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
