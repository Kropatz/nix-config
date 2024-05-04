{ pkgs, config, ...}:
{
  imports = [
    ./acme.nix
    ./adguard.nix
    ./kubernetes.nix
    ./kavita.nix
    ./nginx.nix
    ./fileshelter.nix
    ./wireguard.nix
  ];
}
