{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "samba";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables samba";
  };

  config = lib.mkIf cfg.enable {

  };
}
