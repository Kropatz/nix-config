{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.kop-service-dashboard;
in
{
  options = {
    custom.services.kop-service-dashboard = {
      enable = mkEnableOption "Enable the service dashboard";
      port = mkOption {
        type = types.int;
        default = config.custom.vars.ports.service-dashboard;
      };
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/service-dashboard";
        description = "Directory to store the data";
      };
      basePath = mkOption {
        type = types.str;
        default = "/";
        description = "Location under which the data logger is reachable";
      };
      fqdn = mkOption {
        type = types.str;
        default = "service-dashboard.kopatz.dev";
        description = "FQDN under which the data logger is reachable";
      };
    };
  };

}
