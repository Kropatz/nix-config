{ pkgs, config, ...}:
{
  imports = [
    ./packages-list.nix
    ./backup.nix
    ./btrfs.nix
    ./cli-tools.nix
    ./docker.nix
    ./nftables.nix
    ./static-ip.nix
    ./tmpfs.nix
    ./virt-manager.nix
    ./wireshark.nix
    ./podman.nix
  ];
}
