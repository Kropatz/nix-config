{ config, pkgs, inputs, lib, ... }:
with lib;
let cfg = config.custom.graphical.shared;
in {
  options.custom.graphical.shared = {
    enable = mkEnableOption "Enables shared";
  };

  config = let
    screenshot = pkgs.writeShellScriptBin "screenshot" ''
      ${pkgs.scrot}/bin/scrot -fs - | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png -i
    '';
  in mkIf cfg.enable {
    programs.dconf.enable = true;
    programs.kdeconnect.enable = true;

    fonts.fontDir.enable = true;
    fonts.packages = with pkgs; [
      #uw-ttyp0
      #corefonts
      nerdfonts # noto and hack
      #noto-fonts
      #noto-fonts-emoji
      noto-fonts-cjk
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

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      keepassxc
      xfce.thunar
      remmina
      thunderbird
      localsend
      #element-desktop
      krita
      libreoffice-fresh
      screenshot
      anki
      mpv
      p7zip
      qbittorrent
      brightnessctl
      #wacomtablet
      wl-clipboard
      libsForQt5.kolourpaint
      libsForQt5.kcalc
      syncthingtray
      v4l-utils
      logseq
    ];
  };
}
