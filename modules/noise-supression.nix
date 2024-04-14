{pkgs, ...}:
{
    programs.noisetorch.enable = true;
    environment.systemPackages = [
        pkgs.easyeffects
    ];
}
