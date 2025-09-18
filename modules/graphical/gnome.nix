{ lib, config, pkgs, ... }:
with lib;
let cfg = config.custom.graphical.gnome;
in {
  options.custom.graphical.gnome = { enable = mkEnableOption "Enables gnome"; };

  config = mkIf cfg.enable {
    services.xserver = {
      xkb.layout = config.mainUser.layout;
      xkb.variant = config.mainUser.variant;
      enable = true;
      displayManager.gdm.enable =
        lib.mkIf (!config.custom.graphical.sddm.enable) true;
      desktopManager.gnome.enable = true;
    };

    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;
    services.gnome.gnome-keyring.enable = true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.gnome.excludePackages = (with pkgs; [
      gnome-photos
      gnome-tour
      cheese
      gedit # text editor
      gnome-music
      gnome-terminal
      epiphany # web browser
      #geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]);

    environment.systemPackages = with pkgs; [
      wmctrl
      rofi
      mutter
      adwaita-icon-theme
      gnome-settings-daemon
      gnome-tweaks
      dconf-editor
      #gruvbox-gtk-theme
      colloid-icon-theme
      gnomeExtensions.appindicator
      gnomeExtensions.just-perfection
      gnomeExtensions.system-monitor-2
      gnomeExtensions.dash2dock-lite
      gnomeExtensions.dash-to-dock
      gnomeExtensions.vitals
      gnomeExtensions.rounded-window-corners-reborn
      gnomeExtensions.backslide
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.blur-my-shell
      gnomeExtensions.paperwm
    ];
  };
}
