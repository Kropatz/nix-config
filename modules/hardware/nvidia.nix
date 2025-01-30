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
        extraPackages = with pkgs; [ nvidia-vaapi-driver ];
      };
    } else {
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
    };
  in lib.mkIf cfg.enable (lib.recursiveUpdate nvidiaOption {
    boot.kernelParams =
      [ "nvidia-drm.fbdev=1" "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
    services.xserver.videoDrivers = [ "nvidia" ];
    services.xserver.deviceSection = ''
      Option "Coolbits" "24"
    '';
    hardware.nvidia = {
      # Modesetting is required.
      modesetting.enable = true;
      # Open drivers with gsp stutters in VR - https://github.com/ValveSoftware/SteamVR-for-Linux/issues/631
      gsp.enable = config.hardware.nvidia.open;
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
      #package = config.boot.kernelPackages.nvidiaPackages.beta;
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "570.86.16";
        sha256_64bit = "sha256-RWPqS7ZUJH9JEAWlfHLGdqrNlavhaR1xMyzs8lJhy9U=";
        sha256_aarch64 = "sha256-RiO2njJ+z0DYBo/1DKa9GmAjFgZFfQ1/1Ga+vXG87vA=";
        openSha256 = "sha256-DuVNA63+pJ8IB7Tw2gM4HbwlOh1bcDg2AN2mbEU9VPE=";
        settingsSha256 = "sha256-9rtqh64TyhDF5fFAYiWl3oDHzKJqyOW3abpcf2iNRT8=";
        persistencedSha256 =
          "sha256-3mp9X/oV8o2TH9720NnoXROxQ4g98nNee+DucXpQy3w=";
      };
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

    environment.systemPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      libva
      libva-utils
    ];

    systemd.services.nvpl = lib.mkIf cfg.powerLimit.enable {
      description =
        "Increase GPU power limit to ${toString cfg.powerLimit.wattage} watts";
      script = "/run/current-system/sw/bin/nvidia-smi -pl=${
          toString cfg.powerLimit.wattage
        }";
      wantedBy = [ "multi-user.target" ];
    };
  });
}
