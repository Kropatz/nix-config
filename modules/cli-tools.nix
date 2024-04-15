{ config, pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    pciutils
    nixos-option
    btop
    git
    killall
    xclip
    usbutils
    inputs.agenix.packages."x86_64-linux".default
    fastfetch
    pdfgrep
    ncdu
    glxinfo
    vulkan-tools
    ffmpeg
    nethogs
    dig
    smartmontools
    bc
    xxd
    tldr
    file
    unzip
    lsof
    screen
    tmux
    fatrace # monitor filesystem events
  ];
}
