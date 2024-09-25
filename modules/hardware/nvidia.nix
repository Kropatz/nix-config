{ lib, config, pkgs, inputs, pkgsVersion, ... }:
let cfg = config.custom.hardware.nvidia;
in {
  options.custom.hardware.nvidia = {
    enable = lib.mkEnableOption "Enables nvidia gpus";
    powerLimit = {
      enable = lib.mkEnableOption "Increase GPU power limit";
      wattage = lib.mkOption {
        type = lib.types.int;
        default = 300;
        description = "The power limit to set the GPU to";
      };
    };
  };

  config = let
    # the option was renamed in unstable
    nvidiaOption = if (pkgsVersion == inputs.nixpkgs-unstable) then {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    } else {
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
    };
  in lib.mkIf cfg.enable (lib.recursiveUpdate nvidiaOption {
    boot.kernelParams = [ "nvidia-drm.fbdev=1" ];
    services.xserver.videoDrivers = [ "nvidia" ];
    services.xserver.deviceSection = ''
      Option "Coolbits" "24"
    '';
    hardware.nvidia = {
      # Modesetting is required.
      modesetting.enable = true;
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
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = true;
      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;
      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      #package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      #  version = "560.35.03";
      #  sha256_64bit = "sha256-8pMskvrdQ8WyNBvkU/xPc/CtcYXCa7ekP73oGuKfH+M=";
      #  sha256_aarch64 = "sha256-s8ZAVKvRNXpjxRYqM3E5oss5FdqW+tv1qQC2pDjfG+s=";
      #  openSha256 = "sha256-/32Zf0dKrofTmPZ3Ratw4vDM7B+OgpC4p7s+RHUjCrg=";
      #  settingsSha256 = "sha256-kQsvDgnxis9ANFmwIwB7HX5MkIAcpEEAHc8IBOLdXvk=";
      #  persistencedSha256 =
      #    "sha256-E2J2wYYyRu7Kc3MMZz/8ZIemcZg68rkzvqEwFAL3fFs=";
      #  preInstall = ''
      #    rm -f ./libnvidia-egl-wayland.so*
      #    cp ${pkgs.egl-wayland}/lib/libnvidia-egl-wayland.so.1.* .
      #    chmod 777 ./libnvidia-egl-wayland.so.1.*
      #  '';
      #};
    };

    systemd.services.nvpl = lib.mkIf cfg.powerLimit.enable {
      description = "Increase GPU power limit to ${toString cfg.powerLimit.wattage} watts";
      script = "/run/current-system/sw/bin/nvidia-smi -pl=${toString cfg.powerLimit.wattage}";
      wantedBy = [ "multi-user.target" ];
    };
  });
}
