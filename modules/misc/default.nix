{ pkgs, config, ...}:
{
  imports = [
    ./wireshark.nix
    ./virt-manager.nix
    ./nftables.nix
    ./cli-tools.nix
    ./tmpfs.nix
  ];
}
