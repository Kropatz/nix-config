{ pkgs, config, ...}:
{
  imports = [
    ./kubernetes.nix
    ./kavita.nix
    ./nginx.nix
  ];
}
