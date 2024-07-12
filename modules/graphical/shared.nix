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

    services.tumbler.enable = true; # for thumbnails
    services.gvfs = {
      enable = true; # for file manager, trash support, etc.
      package = pkgs.gvfs;
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      keepassxc
      xfce.thunar # file manager
      discord
      vesktop
      gvfs
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
      pinta # paint
      #qalculate-qt # calculator TODO build broken
      #libsForQt5.kcalc
      syncthingtray
      v4l-utils
      logseq # notes
      xarchiver # archive tool
      ani-cli
    ];
  };
}
