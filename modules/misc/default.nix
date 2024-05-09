{ pkgs, config, ...}:
{
  imports = [
    ./backup.nix
    ./wireshark.nix
    ./virt-manager.nix
    ./nftables.nix
    ./cli-tools.nix
    ./tmpfs.nix
    ./static-ip.nix
    ./docker.nix
  ];
}
