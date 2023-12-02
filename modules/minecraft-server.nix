{ pkgs, ...}:
{
    services.minecraft-server = {
        enable = false;
        eula = true;
        openFirewall = true;
        package = pkgs.unstable.papermc;
    };
}
