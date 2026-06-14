{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "hardening";
  cfg = config.custom.misc.${name};
in
{

  options.custom.misc.${name} = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable hardening options.";
    };
  };

}
