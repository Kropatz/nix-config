{ config, pkgs, inputs, ... }:

let
  keepassWithPlugins = pkgs.keepass.override {
    plugins = [
      pkgs.keepass-keepassrpc
    ];
  };
  screenshot = pkgs.writeShellScriptBin "screenshot.sh" ''
    ${pkgs.scrot}/bin/scrot -fs - | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png -i
  '';
in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  programs.kdeconnect.enable = true;

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    nerdfonts
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    wget
    nixos-option
    kate
    keepassWithPlugins
    jetbrains.idea-ultimate
    jetbrains.rider
    dotnet-sdk_7
    dotnet-runtime_7
    neovim
    htop
    btop
    git
    xfce.thunar
    killall
    xclip
    usbutils
    bun
    inputs.agenix.packages."x86_64-linux".default
    insomnia
    remmina
    nextcloud-client
    #podman-compose
    #arion # docker
    neofetch
    thunderbird
    rofi
    pdfgrep
    taisei
    ncdu
    localsend
    element-desktop
    tetrio-desktop
    krita
    unstable.libreoffice-fresh
    mangohud
    screenshot
    glxinfo
    vulkan-tools
  ];

  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";
  };

  ### docker
  virtualisation.docker.enable = true;
}
