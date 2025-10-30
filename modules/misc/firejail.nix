{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.custom.misc.firejail;
in
{
  options.custom.misc.firejail = {
    enable = lib.mkEnableOption "Enables firejail";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.firejail;
      description = "Firejail package used";
      readOnly = true; # is a constant from the upstream NixOS module for now
    };
    mk = lib.mkOption {
      readOnly = true;
      description = "Utility function to make a wrappedBinaries entry";
      default =
        name:
        {
          pkg,
          profile ? name,
          bin ? name,
        }:
        {
          ${bin} = {
            executable = "${lib.getBin pkg}/bin/${bin}";
            profile = "${config.custom.misc.firejail.package}/etc/firejail/${profile}.profile";
          };
        };
    };
  };

  config = lib.mkIf cfg.enable { programs.firejail.enable = true; };
}
