{ pkgs, config, ...}:
{
    imports = [
        ./fh
        ./games
        ./graphical
        ./hardware
        ./nix
        ./services
        ./support
    ];
}
