{ pkgs, config, ...}:
{
    imports = [
        ./fh
        ./graphical
        ./hardware
        ./nix
        ./services
        ./support
        ./tmpfs.nix
        ./wireshark.nix
        ./virt-manager.nix
        ./nftables.nix
        ./cli-tools.nix
    ];
}
