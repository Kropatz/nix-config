{lib,  config, pkgs, inputs, ... }:
with lib;
let
  cfg = config.custom.cli-tools;
in
{
  options.custom.cli-tools = {
    enable = mkEnableOption "Enables cli-tools";
  };
  
  config = mkIf cfg.enable {
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
      ripgrep
    ];
  };
}

