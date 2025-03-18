{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nmap
    gobuster
    thc-hydra
    seclists
    aircrack-ng
    hashcat
    hashcat-utils
    john
  ];
}
