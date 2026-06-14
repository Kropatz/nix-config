{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.kop-fileshare;
in
{
  options = {
    custom.services.kop-fileshare = {
      enable = mkEnableOption "Enable the file upload server";
      port = mkOption {
        type = types.int;
        default = 7777;
        description = "Port for the file upload server";
      };
      listenAddr = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Listen address for the file upload server";
      };
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/file-upload";
        description = "Directory to store uploaded files";
      };
      basePath = mkOption {
        type = types.str;
        default = "/";
        description = "Location under which the file upload server is reachable";
      };
    };
  };

}
