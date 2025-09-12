{ lib, config, pkgs, ... }:
let cfg = config.custom.graphical.stylix;
in {
  options.custom.graphical.stylix = with lib; {
    enable = mkEnableOption "Enables stylix";
    image = mkOption {
      type = types.path;
      default = ../../tsukasa.jpg;
      description = ''
        The wallpaper to use.
      '';
    };
    base16Scheme = mkOption {
      type = with lib.types; nullOr (oneOf [ path lines attrs ]);
      default = null;
      description = ''
        The base16 scheme to use.
      '';
    };
    override = mkOption {
      type = types.attrs;
      #default = {};
      default = {
        base08 = "ed8796"; # red
        base09 = "f5a97f"; # peach
        base0A = "eed49f"; # yellow
        base0B = "a6da95"; # green
        base0C = "8bd5ca"; # teal
        base0D = "8aadf4"; # blue
        base0E = "c6a0f6"; # mauve
        base0F = "f0c6c6"; # flamingo
      };
      description = ''
        Override the generated colors.
      '';
    };
  };

  # https://danth.github.io/stylix/options/nixos.html
  config = lib.mkIf cfg.enable {

    home-manager = {
      users.${config.mainUser.name}.stylix = {
        enable = true;
        #targets.kde.enable = lib.mkIf config.custom.graphical.i3.enable false;
        base16Scheme = config.stylix.base16Scheme // cfg.override;
      };
    };
    stylix = {
      enable = true;
      autoEnable = lib.mkForce true;
      polarity = "dark";
      image = lib.mkForce cfg.image;
      base16Scheme = lib.mkIf (cfg.base16Scheme != null) cfg.base16Scheme;
      override = cfg.override;
      #base16Scheme = ../../home-manager/themes/yorha/scheme.yml;
      #base16Scheme =
      #  "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
      cursor = {
        size = 24;
        name = "breeze_cursors";
        package = pkgs.kdePackages.breeze;
      };
      opacity = {
        applications = 0.85;
        desktop = 0.85;
        terminal = 0.85;
        popups = 0.85;
      };
      #targets.hyprland.enable = false; does not exist in the MR version yet
      targets = {
        grub.enable = false;
        plymouth.enable = false;
      };
      fonts = {
        serif = config.stylix.fonts.sansSerif;
        sansSerif = {
          package = pkgs.noto-fonts;
          name = "Noto Sans";
        };
        sizes = {
          applications = 12;
          desktop = 10;
          popups = 10;
          terminal = 12;
        };
        monospace = {
          package = pkgs.nerd-fonts.hack;
          name = "Hack";
        };
      };
    };
  };
}
