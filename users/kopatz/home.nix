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
    ../../home-manager/gitconfig.nix
    ../../home-manager/hyprland
    #../../home-manager/kde-path.nix
    ../../home-manager/kitty.nix
    ../../home-manager/lf.nix
    ../../home-manager/nixvim
    ../../home-manager/rofi.nix
    ../../home-manager/dunst.nix
    ../../home-manager/opensnitch-ui.nix
    #../../home-manager/theme.nix
    ../../home-manager/zsh
    ../../home-manager/i3.nix
    ../../home-manager/stylix.nix
    inputs.nixvim.homeManagerModules.nixvim
    inputs.nix-colors.homeManagerModule
  ];

  programs.newsboat = {
    enable = true;
    extraConfig = ''
      bind-key j down
      bind-key k up
      bind-key J next-feed articlelist
      bind-key K prev-feed articlelist
      bind-key G end
      bind-key g home
      bind-key l open
      bind-key h quit

      # general settings
      auto-reload yes
      download-full-page yes
      max-items 100
      # limit width so articles are more readable
      text-width 80
      # solarized
      color background	color223	default
      color listnormal	color4		default
      color listnormal_unread	color2		default
      color listfocus		color223	color237	bold
      color listfocus_unread	color223	color237	bold
      color info		color8		color0
      color article		color223	default

      # highlights
      highlight article "^(Feed|Link):.*$" color11 default bold
      highlight article "^(Title|Date|Author):.*$" color11 default bold
      highlight article "https?://[^ ]+" color2 default underline
      highlight article "\\[[0-9]+\\]" color2 default bold
      highlight article "\\[image\\ [0-9]+\\]" color2 default bold
      highlight feedlist "^─.*$" color6 color6 bold
    '';
    urls = [
      {
        title = "r/NixOS";
        tags = [ "nixos" "nix" "reddit" ];
        url = "https://www.reddit.com/r/NixOS.rss";
      }
      {
        title = "Hacker News";
        url = "https://hnrss.org/newest";
      }
      {
        title = "Phoronix";
        url = "https://www.phoronix.com/rss.php";
      }
      {
        title = "LWN";
        url = "https://lwn.net/headlines/rss";
      }
      {
        title = "/g/";
        tags = [ "4chan" "technology" ];
        url = "https://boards.4channel.org/g/index.rss";
      }
    ];
  };

  #colorScheme = import ../../home-manager/themes/yorha/colors.nix;
}
