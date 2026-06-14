{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "fasterboot";
  cfg = config.custom.misc.${name};
in
{

  options.custom.misc.${name} = {
    enable = lib.mkEnableOption "Enables faster boot";
  };

}
