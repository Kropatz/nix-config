{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.graphical;
in
{

  imports = [
    ./code.nix
    ./sddm.nix
    ./awesome.nix
    ./i3.nix
    ./games.nix
    ./gnome.nix
    ./gnome-settings.nix
    ./hyprland.nix
    ./obs.nix
    ./plasma.nix
    #./stylix.nix
    #./cosmic.nix
    ./shared.nix
    ./basics.nix
    ./gpu-screen-recorder-ui.nix
  ];

  config = lib.mkMerge [
    (lib.mkIf cfg.audio.enable {
      # Enable sound with pipewire.
      security.rtkit.enable = true;

      services.pulseaudio.enable = false;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        #jack.enable = true;
      };
    })
    (lib.mkIf cfg.code.android.enable {
      documentation.dev.enable = true;
      environment.systemPackages = with pkgs; [
        #android-studio
        android-tools
      ];
      users.users.${config.mainUser.name}.extraGroups = [
        "adbusers"
        "kvm"
      ];
    })
    (lib.mkIf cfg.emulators.enable {
      environment.systemPackages = with pkgs; [
        snes9x
      ];
    })
    (lib.mkIf cfg.ime.enable {
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.waylandFrontend = true;
        fcitx5.addons = [ pkgs.fcitx5-mozc ];
      };
    })
    (lib.mkIf cfg.lightdm.enable {
      services.xserver.displayManager = {
        lightdm.enable = true;
        lightdm.greeters.slick.enable = true;
      };
    })
    (lib.mkIf cfg.lxqt.enable {
      services.xserver = {
        xkb.layout = config.mainUser.layout;
        xkb.variant = config.mainUser.variant;
        enable = true;
        #displayManager.sddm.enable = true;
        desktopManager.lxqt.enable = true;
      };
    })
    (lib.mkIf cfg.nightlight.enable {
      location.latitude = 48.2082;
      location.longitude = 16.3738;
      services.redshift.enable = true;
    })
    (lib.mkIf cfg.niri.enable {
      programs.niri = {
        enable = true;
      };
      environment.systemPackages = with pkgs; [ xwayland-satellite ];
    })
    (lib.mkIf cfg.noise-supression.enable {
      environment.systemPackages = with pkgs; [
        easyeffects
      ];
    })
    (lib.mkIf cfg.openrgb.enable {
      services.hardware.openrgb.enable = true;
      services.hardware.openrgb.package = pkgs.openrgb-with-all-plugins;
    })
    (lib.mkIf cfg.qylock.enable {
      security.pam.services.qylock = { };
    })
    (lib.mkIf cfg.sway.enable {
      environment.systemPackages = with pkgs; [
        grim # screenshot functionality
        slurp # screenshot functionality
        wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
        mako # notification system developed by swaywm maintainer
      ];

      # enable sway window manager
      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
      };
    })
    (lib.mkIf cfg.tuigreet.enable {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
            user = "greeter";
          };
        };
      };
    })
    (lib.mkIf cfg.wayvnc.enable {
      environment.systemPackages = with pkgs; [
        wayvnc
      ];
      networking.firewall.allowedTCPPorts = [ 5900 ];
    })
    (lib.mkIf cfg.xfce.enable {
      services.xserver = {
        xkb.layout = config.mainUser.layout;
        xkb.variant = config.mainUser.variant;
        enable = true;
        desktopManager.xfce.enable = true;
      };
    })
  ];

}
