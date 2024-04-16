{ pkgs, config, ...}:
{
  imports = [
    ./fh
    ./graphical
    ./hardware
    ./misc
    ./nix
    ./services
    ./support
  ];
}
