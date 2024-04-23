{ config, pkgs, inputs, ...}:
{
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      # new option autosuggestion.enable = true;
      enableAutosuggestions = true;
      shellAliases = {
          # TODO: gifsicle -O3 --lossy=30 noita-20240328-191617-1612416266-00316616.gif -o noita-20240328-191617-1612416266.gif 
          backupNoita = "cp -r ~/.local/share/Steam/steamapps/compatdata/881100/pfx/drive_c/users/steamuser/AppData/LocalLow/Nolla_Games_Noita/save00 /synced/default/backups/noita_save";
          checkTime = "(cd /synced/work_drive/TS && nix run)";
          checkWaylandWindowsKDE = "qdbus org.kde.KWin /KWin org.kde.KWin.showDebugConsole";
          collectGarbage = "nh clean all";
          edit = "cd ~/projects/github/nix-config && nvim .";
          ll = "ls -l";
          ssh = "TERM=xterm-256color ssh";
          update = "sudo nixos-rebuild switch";
          updateFancy = "nh os switch";
          updateOffline = "sudo nixos-rebuild switch --option substitute false";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "eastwood";
      };
    };
}
