{ pkgs, config, ...}:
{
  imports = [
    ./kubernetes.nix
    ./kavita.nix
  ];
}
