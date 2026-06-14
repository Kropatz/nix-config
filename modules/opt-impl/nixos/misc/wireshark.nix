{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.wireshark;
in
{

  config = mkIf cfg.enable {
    programs.wireshark.enable = true;
    programs.wireshark.package = pkgs.wireshark;

    users.users.${config.mainUser.name}.extraGroups = [ "wireshark" ];
  };
}
