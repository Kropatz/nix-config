{ pkgs, config, ...}:
{
  imports = [
    ./index.nix
    ./ld.nix
    ./settings.nix
  ];
}
