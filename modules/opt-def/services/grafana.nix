{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "grafana";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables grafana";
  };

  config = lib.mkIf cfg.enable {

  };
}
