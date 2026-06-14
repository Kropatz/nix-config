{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.kop-sanitizer-bot;
in
{
  options = {
    custom.services.kop-sanitizer-bot = {
      enable = mkEnableOption "Enable the sanitizer bot";
    };
  };

}
