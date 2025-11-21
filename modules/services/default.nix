{ pkgs, config, ... }:
{
  imports = [
    ./acme.nix
    ./adam-site.nix
    ./adguard.nix
    ./caldav.nix
    ./clamav.nix
    ./dnsmasq.nix
    ./ente.nix
    ./fileshelter.nix
    ./games
    ./github-runner.nix
    ./gitolite.nix
    ./kavita.nix
    ./kop-fileshare.nix
    ./kop-monitor.nix
    ./kop-pvlog.nix
    ./kubernetes.nix
    ./nginx.nix
    ./opensnitch.nix
    ./plausible.nix
    ./smartd.nix
    ./syncthing.nix
    ./wireguard.nix
  ];
}
