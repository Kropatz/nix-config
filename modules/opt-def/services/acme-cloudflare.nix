{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "acme-cloudflare";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables acme-cloudflare";
  };

}
