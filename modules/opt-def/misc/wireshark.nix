{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.wireshark;
in
{
  options.custom.wireshark = {
    enable = mkEnableOption "Enables wireshark";
  };

}
