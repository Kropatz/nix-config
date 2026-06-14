{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.clamav;
in
{
  options.custom.services.clamav = {
    enable = lib.mkEnableOption "Enables clamav";
    enableScanner = lib.mkOption {
      type = with lib.types; bool;
      default = true;
      description = "Enable automatic scanning with clamscan.";
    };
    scanDirectories = lib.mkOption {
      type = with lib.types; listOf str;
      default = [
        "/home"
        "/var/lib"
        "/tmp"
        "/etc"
        "/var/tmp"
      ];
      description = "Directories to scan with clamscan.";
    };
  };
}
