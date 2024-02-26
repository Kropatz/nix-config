{ config, pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    nixos-option
    btop
    git
    killall
    xclip
    usbutils
    inputs.agenix.packages."x86_64-linux".default
    neofetch
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
  ];
}
