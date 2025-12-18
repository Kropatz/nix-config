{ pkgs, config, ... }:
{
  services.easyeffects = {
    enable = true;
    preset = "other_mic";
    extraPresets = {
      mic = builtins.fromJSON (builtins.readFile ./mic.json);
      other_mic = builtins.fromJSON (builtins.readFile ./other_mic.json);
    };
  };
}
