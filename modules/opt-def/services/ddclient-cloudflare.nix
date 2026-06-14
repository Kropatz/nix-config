{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "ddclient-cloudflare";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables ddclient-cloudflare";
  };

  config = lib.mkIf cfg.enable {

  };
}
