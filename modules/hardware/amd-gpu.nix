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
          rev = "0f8753ffb83a635f47cb0c79e8a8f86c5343d1cf";
          hash = "sha256-3Si9bTGO1nUmiJN1X/tIR4vo0EH8Zi2JNUBs2oyuVYM=";
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
