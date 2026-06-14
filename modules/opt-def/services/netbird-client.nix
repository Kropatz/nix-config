{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "netbird-client";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables netbird-client";
  };

  # HOWTO: Enable config, then run netbird-wt0 up --management-url https://netbird.kopatz.dev --setup-key <setup-key>
}
