{ lib, config, pkgs, inputs, pkgsVersion, ... }:
let cfg = config.custom.hardware.amd-gpu;
in {
  options.custom.hardware.amd-gpu = {
    enable = lib.mkEnableOption "Enables amd gpus";
    rocm.enable = lib.mkEnableOption "Enables rocm";
  };

  config =
    lib.mkIf cfg.enable {
      boot.kernelParams =
        [ "amdgpu.ppfeaturemask=0xfff7ffff" "split_lock_detect=off" ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = lib.mkIf cfg.rocm.enable (with pkgs; [ rocmPackages.clr rocmPackages.clr.icd ]);
      };

      hardware.amdgpu.initrd.enable = lib.mkDefault true;
      services.xserver.videoDrivers = [ "amdgpu" ];
      # controller (overclock, undervolt, fan curves)
      environment.systemPackages = with pkgs; [
        lact
        nvtopPackages.amd
        amdgpu_top
      ] ++ lib.optionals cfg.rocm.enable [
        clinfo
        rocmPackages.rocminfo
      ];
      systemd = {
        packages = with pkgs; [ lact ];
        services.lactd.wantedBy = [ "multi-user.target" ];
        #rocm
        tmpfiles.rules =
          let
            rocmEnv = pkgs.symlinkJoin {
              name = "rocm-combined";
              paths = with pkgs.rocmPackages; [
                rocblas
                hipblas
                clr
              ];
            };
          in
          lib.mkIf cfg.rocm.enable
            [
              "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
            ];
      };
    };
}
