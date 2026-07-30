{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.nix;
in
{
  imports = [
    ./ld.nix
    ./settings.nix
  ];

  config = lib.mkMerge [
    (lib.mkIf cfg.index.enable {
      programs.command-not-found.enable = false;
      programs.nix-index = {
        enable = true;
        enableZshIntegration = true;
      };
    })
    (lib.mkIf cfg.sshServe.enable {
      nix.sshServe = {
        enable = true;
        keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2"
        ];
      };
    })
    (lib.mkIf cfg.useLatest {
      nix.package = pkgs.nixVersions.latest;
    })
  ];
}
