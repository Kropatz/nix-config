{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "fail2ban";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables fail2ban";
  };

}
