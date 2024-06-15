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
      rippkgs # faster nixpkgs search, init with `rippkgs-index nixpkgs && mv rippkgs-index.sqlite ~/.local/share/`; 
      nixos-option
      btop
      git
      gh #github
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
      lshw
      screen
      tmux
      fatrace # monitor filesystem events
      ripgrep
      nh
      nix-output-monitor # nom
      nvd # nix diff, example: nvd diff /nix/var/nix/profiles/system-389-link /nix/var/nix/profiles/system-390-link
      compsize
      trashy # move files to trash
      fzf # fuzzy finder
      bat # fancy cat
      shell-gpt
      libheif #convert heic to jpg with `heif-convert something.heic something.jpg` 
      tree
    ];
  };
}

