{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "jellyfin";
  cfg = config.custom.services.${name};
in
{

  config = lib.mkIf cfg.enable {
    users.users.jellyfin.extraGroups = [ "transmission" ];
    services.jellyfin = {
      enable = true;
    };
  };
}
