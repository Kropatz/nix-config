{ config, pkgs, inputs, lib, ... }:
with lib;
let cfg = config.custom.graphical.shared;
in {
  options.custom.graphical.shared = {
    enable = mkEnableOption "Enables shared";
  };

  config =
    let
      screenshot = pkgs.writeShellScriptBin "screenshot" ''
        ${pkgs.scrot}/bin/scrot -fs - | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png -i
      '';
    in
    mkIf cfg.enable {
      programs.dconf.enable = true;

      fonts.fontDir.enable = true;
      fonts.packages = with pkgs; [
        #uw-ttyp0
        #corefonts
        nerd-fonts.noto
        nerd-fonts.hack
        #noto-fonts
        #noto-fonts-emoji
        noto-fonts-cjk-sans
        #font-awesome
      ];
      services.libinput = {
        enable = true;

        # disabling mouse acceleration
        mouse = {
          accelProfile = "flat";
          middleEmulation = false;
        };
      };
      programs.kdeconnect.enable = true;
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 25565 53317 ]; # localsend
        allowedUDPPorts = [ 1194 53317 ]; # openvpn, localsend
        allowedTCPPortRanges = [{
          from = 1714;
          to = 1764;
        } # KDE Connect
        ];
        allowedUDPPortRanges = [{
          from = 1714;
          to = 1764;
        } # KDE Connect
        ];
      };

      #services.xserver.wacom.enable = true;
      services.tumbler.enable = true; # for thumbnails
      programs.file-roller.enable = true;
      programs.thunar.enable = true;
      programs.thunar.plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
      services.gvfs.enable = true; # for file manager, trash support, etc.

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        keepassxc
        screenshot
        wl-clipboard
        xarchiver # archive tool
        adwaita-icon-theme
      ];
    };
}
