{ config, pkgs, inputs, lib, ... }:
with lib;
let cfg = config.custom.graphical.basics;
in {
  options.custom.graphical.basics = {
    enable = mkEnableOption "Enables basics";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      keepassxc
      discord-canary
      gvfs
      remmina
      thunderbird
      localsend
      #element-desktop
      krita
      libreoffice
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
      ani-cli
      mangal-patched
    ];
  };
}
