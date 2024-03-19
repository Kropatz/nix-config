{ pkgs, ...} :
{
    environment.systemPackages = with pkgs; [
        regripper
        foremost
        binwalk
        sleuthkit
        samdump2
        apktool
    ];
}
