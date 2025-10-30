{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.cli-tools;
in
{
  options.custom.cli-tools = {
    enable = mkEnableOption "Enables cli-tools";
  };

  config =
    let
      getTotalPowerUsed = pkgs.writeShellScriptBin "total-power" ''
        echo "$(sudo cat /sys/class/powercap/*/energy_uj | awk 'BEGIN { sum = 0; } { sum += $1; } END { print sum; }' "$@") / 1000000" | bc | xargs -I _ echo "_ W"
      '';
      watchCurrentPowerUsed = pkgs.writeShellScriptBin "watch-current-power" ''
        function getCurrentPowerUsed() {
          local energy_uj=$(sudo cat $energy_path | awk 'BEGIN { sum = 0; } { sum += $1; } END { print sum; }' "$@")
          echo "scale=2; $energy_uj / 1000000" | bc
        }

        energy_path=$(grep package /sys/class/powercap/*/name | sed 's/name.*$/energy_uj/')
        power_prev=0
        power_curr=$(getCurrentPowerUsed)
        while true; do
          power_prev=$power_curr
          sleep 1
          power_curr=$(getCurrentPowerUsed)
          echo "scale=2; ($power_curr - $power_prev) / 1" | bc | xargs -I _ echo "_ W"
        done
      '';
    in
    mkIf cfg.enable {

      #Fuse filesystem that returns symlinks to executables based on the PATH of the requesting process.
      #This is useful to execute shebangs on NixOS that assume hard coded locations in locations like /bin or /usr/bin etc.
      services.envfs.enable = true;

      # enables fzf and integration with bash/zsh/fish
      programs.fzf = {
        fuzzyCompletion = true;
        keybindings = true;
      };

      environment.etc."tmux.conf".text = ''
        set -g mouse on
        set -g allow-passthrough on
        set -g set-clipboard on
        set -g prefix C-space
      '';

      environment.systemPackages = with pkgs; [
        getTotalPowerUsed
        watchCurrentPowerUsed
        (if lib.versionOlder lib.version "25.05" then wget else powerjoular) # monitor power usage
        bat # fancy cat
        fd # nicer find
        duf # nicer du
        eza # nicer ls
        ripgrep # faster grep
        gdu
        wget
        pciutils
        rippkgs # faster nixpkgs search, init with `rippkgs-index nixpkgs && mv rippkgs-index.sqlite ~/.local/share/`;
        nixos-option
        btop
        git
        gh # github
        killall
        #xclip
        usbutils
        inputs.agenix.packages."x86_64-linux".default
        fastfetch
        pdfgrep
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
        nh
        nix-output-monitor # nom
        nvd # nix diff, example: nvd diff /nix/var/nix/profiles/system-389-link /nix/var/nix/profiles/system-390-link
        compsize
        trashy # move files to trash
        #shell-gpt #openai bitches stole my credits :(
        answer
        libheif # convert heic to jpg with `heif-convert something.heic something.jpg`
        imagemagick # convert images
        tree
        kop-newproject # creates a shell.nix and .envrc
        nix-tree # show nix derivations
        binwalk # show what's inside a binary
        iotop
        inetutils
        nettools
        wireguard-tools
      ];
    };
}
