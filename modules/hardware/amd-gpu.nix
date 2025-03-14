{ lib, config, pkgs, inputs, pkgsVersion, ... }:
let cfg = config.custom.hardware.amd-gpu;
in {
  options.custom.hardware.amd-gpu = {
    enable = lib.mkEnableOption "Enables amd gpus";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff"  "split_lock_detect=off" ];
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      package = lib.mkForce pkgs.mesa-git.mesa.drivers;
      #extraPackages = with pkgs; [ mesa-git.amdvlk ];
    };

    boot.initrd.kernelModules = [ "amdgpu" ];
    services.xserver.videoDrivers = [ "amdgpu" ];
    # controller (overclock, undervolt, fan curves)
    environment.systemPackages = with pkgs; [ lact nvtopPackages.amd ];
    systemd.packages = with pkgs; [ lact ];
    systemd.services.lactd.wantedBy = [ "multi-user.target" ];

    hardware.firmware = with pkgs;
      [
        (linux-firmware.overrideAttrs (old: {
          src = builtins.fetchGit {
            url =
              "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
            rev =
              "b4cb02b2dc3330c6e5d69e84a616b1ca5faecf12"; # Uncomment this line to allow for pure builds
          };
        }))
      ];
  };
}
