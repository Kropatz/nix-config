{ config, pkgs, inputs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    initExtra = ''
      compressImage () {
        magick $1 -strip -resize 1920x1080 -quality 85% compressed.jpg
      }
    '';
    shellAliases = {
      # TODO: gifsicle -O3 --lossy=30 noita-20240328-191617-1612416266-00316616.gif -o noita-20240328-191617-1612416266.gif 
      backupNoita =
        "cp -r ~/.local/share/Steam/steamapps/compatdata/881100/pfx/drive_c/users/steamuser/AppData/LocalLow/Nolla_Games_Noita/* /synced/default/backups/noita_save";
      checkTime = "(cd /synced/work_drive/TS && nix run)";
      checkWaylandWindowsKDE =
        "qdbus org.kde.KWin /KWin org.kde.KWin.showDebugConsole";
      collectGarbage = "nh clean all";
      edit = "cd ~/projects/github/nix-config && nvim .";
      ll = "ls -l";
      ls = "${pkgs.eza}/bin/eza --icons always";
      la = "${pkgs.eza}/bin/eza -la --icons --group-directories-first";
      ssh = "TERM=xterm-256color ssh";
      update = "sudo nixos-rebuild switch";
      updateFancy = "nh os switch";
      updateOffline = "sudo nixos-rebuild switch --option substitute false";
      goto = "cd $(find -L ~/projects -maxdepth 2 -type d | ${pkgs.fzf}/bin/fzf)";
      dev = "nix-shell --run zsh";
      rmt = "trash put";
      bat = "bat -P --style plain";
      cdf =
        "cd $(fd --type d --exclude node_modules --exclude bin --exclude target --exclude .cache . | fzf)";
      cpu_performance =
        "echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor";
      cpu_powersave =
        "echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor";
      cpu_schedutil =
        "echo schedutil | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor";
      cpu_freq = ''watch -n 1 "cat /proc/cpuinfo | grep \"^[c]pu MHz\""'';
      gpu_monitor = "nvidia-smi dmon -s puct";
    };
    #plugins = with pkgs; [
    #  {
    #    name = "powerlevel10k";
    #    src = "${zsh-powerlevel10k}/share/zsh-powerlevel10k";
    #    file = "powerlevel10k.zsh-theme";
    #  }
    #  {
    #    name = "powerlevel10k-config";
    #    src = ./.;
    #    file = ".p10k.zsh";
    #  }
    #];

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "eastwood";
    };
  };
}
