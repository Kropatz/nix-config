{ pkgs, ...} :
{
    environment.systemPackages = with pkgs; [
        regripper
        volatility3
        foremost
        binwalk
    ];
}
