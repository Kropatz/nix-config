{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.gitea;
in
{
  options.custom.services.gitea = {
    enable = lib.mkEnableOption "Enables gitea";
    fqdn = lib.mkOption {
      type = lib.types.str;
      default = "git.kopatz.dev";
      description = "FQDN under which gitea is available";
    };
  };
}
