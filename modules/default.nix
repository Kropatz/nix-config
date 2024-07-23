{ pkgs, config, ...}:
{
  imports = [
    ./fh
    ./hardware
    ./misc
    ./nix
    ./services
    ./support
  ];
}
