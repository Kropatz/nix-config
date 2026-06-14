{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "zram";
  cfg = config.custom.misc.${name};
in
{

  options.custom.misc.${name} = {
    enable = lib.mkEnableOption "Enables zram";
  };

}
