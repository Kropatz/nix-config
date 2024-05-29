{ pkgs, config, ...}:
{
  imports = [
    ./firmware.nix
    ./nvidia.nix
    ./scheduler.nix
    ./ssd.nix
    ./vfio.nix
    ./wooting.nix
    ./tpm.nix
    ./tablet.nix
  ];
}
