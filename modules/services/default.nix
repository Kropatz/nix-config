{ pkgs, config, ...}:
{
  imports = [
    ./acme.nix
    ./caldav.nix
    ./opensnitch.nix
    ./github-runner.nix
    ./adguard.nix
    ./dnsmasq.nix
    ./games
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
    ./syncthing.nix
  ];
}
