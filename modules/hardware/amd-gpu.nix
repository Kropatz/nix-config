{ lib, config, pkgs, inputs, pkgsVersion, ... }:
let cfg = config.custom.hardware.amd-gpu;
in {
  options.custom.hardware.amd-gpu = {
    enable = lib.mkEnableOption "Enables amd gpus";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams =
      [ "amdgpu.ppfeaturemask=0xfff7ffff" "split_lock_detect=off" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      package = lib.mkForce pkgs.mesa-git.mesa.drivers;
      extraPackages = with pkgs; [ mesa-git.amdvlk ];
    };

    hardware.amdgpu.initrd.enable = lib.mkDefault true;
    services.xserver.videoDrivers = [ "amdgpu" ];
    # controller (overclock, undervolt, fan curves)
    environment.systemPackages = with pkgs; [
      lact
      nvtopPackages.amd
      amdgpu_top
    ];
    systemd.packages = with pkgs; [ lact ];
    systemd.services.lactd.wantedBy = [ "multi-user.target" ];
  };
}
