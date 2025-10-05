{ osConfig, config, pkgs, inputs, lib, ... }: {
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
    inputs.nixvim.homeManagerModules.nixvim
  ];

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
      prev_img = [ "h" "Left" ];
      next_img = [ "l" "Right" ];
    };
  };

  xdg.desktopEntries = {
    notes = {
      name = "Notes";
      exec = "kitty nvim /synced/default/notes.md";
      icon = "nvim";
      type = "Application";
      categories = [ "Utility" "TextEditor"  ];
      mimeType = [ "text/markdown" "text/plain" ];
    };
  };
}
