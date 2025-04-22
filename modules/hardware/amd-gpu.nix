{ lib, config, pkgs, inputs, pkgsVersion, ... }:
let cfg = config.custom.hardware.amd-gpu;
in {
  options.custom.hardware.amd-gpu = {
    enable = lib.mkEnableOption "Enables amd gpus";
    rocm.enable = lib.mkEnableOption "Enables rocm";
  };

  config =
    let
      mesa-new = pkgs.mesa.overrideAttrs (old: {
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "mesa";
          repo = "mesa";
          rev = "93547d45ceb0a59f429f6029b339c044f8aaabaa";
          hash = "sha256-u5Lksclv0+cMfO02Ilp6v/7UCoTdm5veIvf1uejWlgQ=";
        };
        patches = [
          ./opencl.patch
        ];
      });

      #mesa-new = pkgs.mesa-git.mesa.overrideAttrs (oldAttrs: {
      #  src = pkgs.fetchFromGitLab {
      #    domain = "gitlab.freedesktop.org";
      #    owner = "hakzsam";
      #    repo = "mesa";
      #    rev = "9238ae542f15e4566430a540817e15a8ec079a59";
      #    hash = "sha256-c/iV/V7m3GuatEuybaetHVIPm66/a6lC1wvV/GGtvnQ=";
      #  };
      #});
    in
    lib.mkIf cfg.enable {
      boot.kernelParams =
        [ "amdgpu.ppfeaturemask=0xfff7ffff" "split_lock_detect=off" ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        package = lib.mkForce mesa-new;
        #extraPackages = with pkgs; [ mesa-git.amdvlk ];
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
      systemd.packages = with pkgs; [ lact ];
      systemd.services.lactd.wantedBy = [ "multi-user.target" ];
      #rocm
      systemd.tmpfiles.rules =
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
}
