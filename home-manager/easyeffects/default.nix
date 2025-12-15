{ pkgs, config, ... }:
{
  services.easyeffects = {
    enable = true;
    preset = "mic";
    extraPresets = {
      mic = builtins.fromJSON (builtins.readFile ./mic.json);
    };
  };
}
