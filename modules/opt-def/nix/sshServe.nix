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
  options.custom.nix.sshServe = {
    enable = mkEnableOption "Enable serving the nix cache over ssh";
  };

}
