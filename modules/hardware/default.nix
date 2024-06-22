{ pkgs, config, ... }: {
  imports = [
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
  ];
}
