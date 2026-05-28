{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "dependency-track";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables depedency-track";
  };

  config = lib.mkIf cfg.enable {
    services.dependency-track = {
      enable = true;
      port = config.custom.vars.ports.dtrack;
      database = {
        type = "h2";
        passwordFile = pkgs.writeText "dtrack-password" "dontcaresorry";
      };
      nginx.domain = "dtrack.kopatz.dev";
      nginx.enable = true;
    };
    services.nginx.virtualHosts."dtrack.kopatz.dev" = {
      useACMEHost = "kopatz.dev";
    };
  };
}
