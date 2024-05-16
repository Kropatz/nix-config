{ pkgs, config, ...}:
{
  imports = [
    ./acme.nix
    ./adguard.nix
    ./ente.nix
    ./kubernetes.nix
    ./kavita.nix
    ./nginx.nix
    ./fileshelter.nix
    ./wireguard.nix
  ];
}
