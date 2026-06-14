{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "blocklist";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables blocklist";
  };

  config = lib.mkIf cfg.enable {

  };
}
