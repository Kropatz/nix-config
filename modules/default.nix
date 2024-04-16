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
    ];
}
