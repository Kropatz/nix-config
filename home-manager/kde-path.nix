{ config, ... }:
{
    home.file."path.sh" = {
      enable = true;
      recursive = true;
      executable = true;
      text = ''
        #!/usr/bin/env sh
        if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
            export MOZ_DBUS_REMOTE="1"
            export KITTY_ENABLE_WAYLAND="1"
            export _JAVA_AWT_WM_NONREPARENTING="1"
            export MOZ_ENABLE_WAYLAND="1"
            export WLR_NO_HARDWARE_CURSORS="1"
            export NIXOS_OZONE_WL="1"

            export LIBVA_DRIVER_NAME="nvidia"
            export __GLX_VENDOR_LIBRARY_NAME="nvidia"
            export GBM_BACKEND="nvidia-drm"

            export XDG_SESSION_TYPE="wayland"
            export QT_QPA_PLATFORM="wayland;xcb"
            export ELECTRON_OZONE_PLATFORM_HINT="wayland"
        fi
      '';
      target = ".config/plasma-workspace/env/path.sh";
    };
   # home.file."path.desktop" = {
   #   enable = true;
   #   recursive = true;
   #   executable = true;
   #   text = ''
   #     [Desktop Entry]
   #     Type=Application
   #     Exec=${config.xdg.configHome}/autostart/path.sh
   #     Hidden=false
   #     NoDisplay=false
   #     X-GNOME-Autostart-enabled=true
   #     Name[en_US]=Login Script
   #     Name=Login Script
   #     Comment[en_US]=Launches login script and sets environment variables
   #     Comment=Launches login script and sets environment variables
   #   '';
   #   target = ".config/autostart/path.desktop";
   # };

}
