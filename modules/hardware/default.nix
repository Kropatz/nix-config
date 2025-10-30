{ pkgs, config, ... }:
{
  imports = [
    ./amd-gpu.nix
    ./android.nix
    ./firmware.nix
    ./nvidia.nix
    ./scheduler.nix
    ./ssd.nix
    ./vfio.nix
    ./wooting.nix
    ./tpm.nix
    ./tablet.nix
    ./fingerprint.nix
    ./vr.nix
  ];
}
