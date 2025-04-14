{ lib, config, pkgs, inputs, pkgsVersion, ... }:
let cfg = config.custom.hardware.amd-gpu;
in {
  options.custom.hardware.amd-gpu = {
    enable = lib.mkEnableOption "Enables amd gpus";
  };

  config =
    let
      mesa-new = pkgs.mesa.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "mesa";
          repo = "mesa";
          rev = "f23b376e847602d4fe7976f3bbb877dfd9d8b417";
          hash = "sha256-prPhezquh63OFkFdYNCRN1OkdwA+CTu88hUoHQD5kCw=";
        };
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
        package = lib.mkForce mesa-new.drivers;
        #extraPackages = with pkgs; [ mesa-git.amdvlk ];
          #extraPackages = with pkgs; [ rocmPackages.clr.icd ];
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
      #rocm
        #systemd.tmpfiles.rules =
        #  let
        #    rocmEnv = pkgs.symlinkJoin {
        #      name = "rocm-combined";
        #      paths = with pkgs.rocmPackages; [
        #        rocblas
        #        hipblas
        #        clr
        #      ];
        #    };
        #  in
        #  [
        #    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
        #  ];
    };
}
