{ lib, ... }:
{
  options.custom.nix = {
    useLatest = lib.mkEnableOption "Use latest nix versions";
    index.enable = lib.mkEnableOption "Enables nix index";
    ld.enable = lib.mkEnableOption "Enables nix ld";
    settings = {
      enable = lib.mkEnableOption "Enables various nix settings";
      optimise = lib.mkOption {
        type = with lib.types; bool;
        default = true;
        description = "Optimise nix store";
      };
    };
    sshServe.enable = lib.mkEnableOption "Enable serving the nix cache over ssh";
  };
}
