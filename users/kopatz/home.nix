{
  osConfig,
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  home = {
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.05";
  };

  imports = [
    ../../home-manager/code.nix
    ../../home-manager/fastfetch.nix
    ../../home-manager/direnv.nix
    ../../home-manager/firefox
    #../../home-manager/floorp
    ../../home-manager/gitconfig.nix
    ../../home-manager/hyprland
    #../../home-manager/kde-path.nix
    ../../home-manager/kitty.nix
    #../../home-manager/lf.nix broken atm
    ../../home-manager/nixvim # nixvim adds ~2-3 secs to eval time even when just using programs.nixvim.enable = true;
    ../../home-manager/rofi
    ../../home-manager/dunst.nix
    ../../home-manager/opensnitch-ui.nix
    #../../home-manager/theme.nix
    ../../home-manager/zsh
    ../../home-manager/i3.nix
    ../../home-manager/stylix.nix
    ../../home-manager/mpv.nix
    ../../home-manager/discord-theme.nix
    ../../home-manager/vr.nix
    inputs.nixvim.homeModules.nixvim
    #  inputs.stylix.homeModules.stylix
  ];

  # stylix.enable = osConfig.custom.graphical.stylix.enable;
  #stylix.image = if (config.stylix.enable == false) then ../../wallpaper/ina.jpg else null;
  programs.feh = {
    enable = true;
    buttons = {
      # Unbind existing scroll operations
      prev_img = null;
      next_img = null;
      # Set <action> <mouse button>
      zoom_in = 4;
      zoom_out = 5;
    };
    keybindings = {
      prev_img = [
        "h"
        "Left"
      ];
      next_img = [
        "l"
        "Right"
      ];
    };
  };
  services.easyeffects = {
    enable = true;
    preset = "better-mic";
    extraPresets = {
      better-mic = {
        input = {
          blocklist = [ ];
          "plugins_order" = [
            "rnnoise#0"
            "speex#0"
            "deepfilternet#0"
          ];
          "rnnoise#0" = {
            bypass = false;
            "enable-vad" = false;
            "input-gain" = 0.0;
            "model-path" = "";
            "output-gain" = 0.0;
            release = 20.0;
            "vad-thres" = 80.0;
            wet = 0.0;
          };
          "deepfilternet#0" = {
            "attenuation-limit" = 100.0;
            "max-df-processing-threshold" = 20.0;
            "max-erb-processing-threshold" = 30.0;
            "min-processing-buffer" = 0;
            "min-processing-threshold" = -10.0;
            "post-filter-beta" = 0.02;
          };
          "speex#0" = {
            "bypass" = false;
            "enable-agc" = true;
            "enable-denoise" = true;
            "enable-dereverb" = true;
            "input-gain" = 0.0;
            "noise-suppression" = -70;
            "output-gain" = 0.0;
            "vad" = {
              "enable" = true;
              "probability-continue" = 90;
              "probability-start" = 95;
            };
          };
        };
      };
    };
  };

  xdg.desktopEntries = {
    notes = {
      name = "Notes";
      exec = "kitty -d /home/kopatz/synced/default/vimwiki nvim /home/kopatz/synced/default/vimwiki/index.md";
      icon = "nvim";
      type = "Application";
      categories = [
        "Utility"
        "TextEditor"
      ];
      mimeType = [
        "text/markdown"
        "text/plain"
      ];
    };
  };
}
