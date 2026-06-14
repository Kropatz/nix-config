{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.custom.misc.podman;
in
{
  options = {
    custom.misc.podman = {
      enable = lib.mkEnableOption "Enable podman service";
    };
  };
}
