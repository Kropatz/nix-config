{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "coturn";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables coturn";
  };

  config = lib.mkIf cfg.enable {

  };
}
