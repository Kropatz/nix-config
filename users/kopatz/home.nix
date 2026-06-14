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
    ../../modules/opt-impl/home-manager/default.nix
    ../../modules/opt-impl/home-manager/code.nix
    ../../modules/opt-impl/home-manager/direnv.nix
    ../../modules/opt-impl/home-manager/firefox
    ../../modules/opt-impl/home-manager/gitconfig.nix
    ../../modules/opt-impl/home-manager/hyprland
    ../../modules/opt-impl/home-manager/kitty.nix
    ../../modules/opt-impl/home-manager/nixvim # nixvim adds ~2-3 secs to eval time even when just using programs.nixvim.enable = true;
    ../../modules/opt-impl/home-manager/rofi
    ../../modules/opt-impl/home-manager/dunst.nix
    ../../modules/opt-impl/home-manager/opensnitch-ui.nix
    ../../modules/opt-impl/home-manager/zsh
    ../../modules/opt-impl/home-manager/i3.nix
    ../../modules/opt-impl/home-manager/stylix.nix
    ../../modules/opt-impl/home-manager/mpv.nix
    ../../modules/opt-impl/home-manager/discord-theme.nix
    ../../modules/opt-impl/home-manager/vr.nix
    ../../modules/opt-impl/home-manager/easyeffects
    ../../modules/opt-impl/home-manager/pnpm.nix
    #../../home-manager/floorp
    #../../home-manager/kde-path.nix
    #../../home-manager/lf.nix broken atm
    # ../../home-manager/fastfetch.nix
    #../../home-manager/theme.nix
    inputs.nixvim.homeModules.nixvim
    #  inputs.stylix.homeModules.stylix
  ];

  home.sessionPath = [ "/home/kopatz/.local/bin" ];

  programs.helix = {
    enable = false;
    settings = {
      editor = {
        completion-trigger-len = 1;
        completion-timeout = 5;
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
      }
    ];
  };

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
