{ lib, config, pkgs, inputs, pkgsVersion, ... }:
let cfg = config.custom.hardware.amd-gpu;
in {
  options.custom.hardware.amd-gpu = {
    enable = lib.mkEnableOption "Enables amd gpus";
  };

  config =
    let
      mesa-new = pkgs.mesa-git.mesa.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "mesa";
          repo = "mesa";
          rev = "69a08fd9b229ee9e859bfca5f4f9052c84714f98";
          hash = "sha256-6vRcad3a3A/9945gkeFgRrjyoBrtsnZeDnG/zROIA2Q=";
        };
      });
    in
    lib.mkIf cfg.enable {
      boot.kernelParams =
        [ "amdgpu.ppfeaturemask=0xfff7ffff" "split_lock_detect=off" ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        package = lib.mkForce mesa-new.drivers;
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
