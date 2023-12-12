{ config, pkgs, ... }:
{
    programs.wireshark.enable = true;
    programs.wireshark.package = pkgs.wireshark;

    users.users.${config.mainUser.name}.extraGroups = [ "wireshark" ];
}
