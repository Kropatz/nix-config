{ lib, config, pkgs, inputs, pkgsVersion, ... }:
let cfg = config.custom.hardware.amd-gpu;
in {
  options.custom.hardware.amd-gpu = {
    enable = lib.mkEnableOption "Enables amd gpus";
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.kernelModules = [ "amdgpu" ];
    services.xserver.videoDrivers = [ "amdgpu" ];
  };
}
