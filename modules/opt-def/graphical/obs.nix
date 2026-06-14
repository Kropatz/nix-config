{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.obs;
in
{
  options.custom.graphical.obs = {
    enable = mkEnableOption "Enables obs";
  };

}
