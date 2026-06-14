{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.kop-pvlog;
in
{
  options = {
    custom.services.kop-pvlog = {
      enable = mkEnableOption "Enable the fronius data logger";
      port = mkOption {
        type = types.int;
        default = 7788;
        description = "Port for the fronius data logger";
      };
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/pvlog";
        description = "Directory to store the data";
      };
      basePath = mkOption {
        type = types.str;
        default = "/";
        description = "Location under which the data logger is reachable";
      };
      fqdn = mkOption {
        type = types.str;
        default = "pvlog.kopatz.dev";
        description = "FQDN under which the data logger is reachable";
      };
      useStepCa = mkOption {
        type = types.bool;
        default = false;
        description = "Use step-ca for ACME certificates";
      };
    };
  };

}
