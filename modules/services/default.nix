{ pkgs, config, ...}:
{
  imports = [
    ./acme.nix
    ./adguard.nix
    ./dnsmasq.nix
    ./gitolite.nix
    ./ente.nix
    ./kubernetes.nix
    ./kavita.nix
    ./nginx.nix
    ./fileshelter.nix
    ./wireguard.nix
    ./kop-monitor.nix
    ./kop-fileshare.nix
    ./adam-site.nix
    ./plausible.nix
  ];
}
