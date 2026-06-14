{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.nix.sshServe;
in
{

  config = mkIf cfg.enable {
    nix.sshServe = {
      enable = true;
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2"
      ];
    };
  };
}
