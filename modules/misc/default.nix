{ pkgs, config, ... }:
{
  imports = [
    ./backup.nix
    ./btrfs.nix
    ./cli-tools.nix
    ./docker.nix
    ./faster-boot-time.nix
    ./firejail.nix
    ./kernel.nix
    ./nftables.nix
    ./nixvim.nix
    ./packages-list.nix
    ./podman.nix
    ./static-ip.nix
    ./tmpfs.nix
    ./virt-manager.nix
    ./wireshark.nix
    ./zram.nix
  ];
}
