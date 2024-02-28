{ pkgs, ...} :
{
    environment.systemPackages = with pkgs; [
        regripper
        foremost
        binwalk
    ];
}
