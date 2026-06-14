{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "tdata";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables tdata";
  };

  config = lib.mkIf cfg.enable {

  };
}
