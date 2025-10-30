{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.gitolite;
in
{
  options.custom.services.gitolite = {
    enable = lib.mkEnableOption "Enables ente";
  };
  # configure git clone gitolite@server:gitolite-admin
  # help ssh gitolite@server help
  config = lib.mkIf cfg.enable {
    services.gitolite = {
      enable = true;
      adminPubkey = config.mainUser.sshKey;
    };
  };
}
