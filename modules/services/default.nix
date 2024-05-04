{ pkgs, config, ...}:
{
  imports = [
    ./acme.nix
    ./kubernetes.nix
    ./kavita.nix
    ./nginx.nix
  ];
}
