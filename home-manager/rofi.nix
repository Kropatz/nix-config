{ config, pkgs, inputs, ...}:
{
    home.file.".config/rofi" = {
      enable = true;
      recursive = true;
      source = ../.config/rofi;
      target = ".config/rofi";
    };
}
