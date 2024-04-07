{ pkgs, ...} :
{
    environment.systemPackages = with pkgs; [
        nmap
        gobuster
        thc-hydra
        seclists
        aircrack-ng
    ];
}
