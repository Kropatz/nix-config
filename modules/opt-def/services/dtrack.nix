{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "dependency-track";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables depedency-track";
  };

}
