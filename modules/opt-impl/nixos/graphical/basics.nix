{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.basics;
in
{

  config = mkIf cfg.enable {
    # logseq
    nixpkgs.config.permittedInsecurePackages = [
      "electron-39.8.10"
    ];

    environment.systemPackages = with pkgs; [
      keepassxc
      discord
      gvfs
      remmina
      thunderbird
      localsend
      #element-desktop
      #krita
      gimp3
      libreoffice
      # (libreoffice.overrideAttrs (old: {
      #   doCheck = false;
      # }))
      #   .override {
      #     langs = ["en-US" "de"];
      # })
      hunspell # needed for libreoffice spellcheck
      hunspellDicts.en_US-large
      hunspellDicts.de_AT
      #anki TODO broken because pyqt6 build fails
      p7zip
      qbittorrent
      brightnessctl
      #wacomtablet
      pinta # paint
      #qalculate-qt # calculator TODO build broken
      #libsForQt5.kcalc
      #syncthingtray #doesnt work with socket yet
      v4l-utils
      logseq # notes
      # ((import
      #   (fetchTarball {
      #     url = "https://github.com/NixOS/nixpkgs/archive/567a49d1913ce81ac6e9582e3553dd90a955875f.tar.gz";
      #     sha256 = "1vq77hlx8mi3z03pw2nf6r5h7473r1p9yxyf58ym3fh01zppmfln";
      #   })
      #   {
      #     config.permittedInsecurePackages = [ "electron-39.8.10" ];
      #     system = pkgs.stdenv.hostPlatform.system;
      #   }
      # ).logseq
      # )
      ani-cli
      # (ani-cli.overrideAttrs {
      #   version = "99";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "justchokingaround";
      #     repo = "ani-cli";
      #     rev = "bd6d5c8ffd6691b7c4a5319bd0f6cfbe249eeae8";
      #     hash = "sha256-u/udZXKq4UDWyN3gKfuRgVw9TkEPrlnHsD9LKu3kJqE=";
      #   };
      #   runtimeInputs = with pkgs; [
      #     gnugrep
      #     gnused
      #     curl
      #     fzf
      #     ffmpeg
      #     aria2
      #     openssl
      #   ];
      # })
      brave

      # cli tools
      mesa-demos
      vulkan-tools
    ];
  };
}
