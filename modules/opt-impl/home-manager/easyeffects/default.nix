{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.custom.graphical.noise-supression.enable {
    services.easyeffects = {
      enable = true;
      preset = "mic";
      extraPresets = {
        mic = builtins.fromJSON (builtins.readFile ./mic.json);
        other_mic = builtins.fromJSON (builtins.readFile ./other_mic.json);
      };
    };
  };
}
