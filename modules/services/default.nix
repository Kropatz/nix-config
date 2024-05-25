{ pkgs, config, ...}:
{
  imports = [
    ./acme.nix
    ./adguard.nix
    ./dnsmasq.nix
    ./ente.nix
    ./kubernetes.nix
    ./kavita.nix
    ./nginx.nix
    ./fileshelter.nix
    ./wireguard.nix
    ./kop-monitor.nix
    ./adam-site.nix
  ];
}
