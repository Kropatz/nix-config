{ config, pkgs, inputs, ...}:
{
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      # new option autosuggestion.enable = true;
      enableAutosuggestions = true;
      shellAliases = {
          ll = "ls -l";
          update = "sudo nixos-rebuild switch";
          updateOffline = "sudo nixos-rebuild switch --option substitute false";
          checkTime = "(cd ~/Nextcloud/work_drive/TS && nix run)";
          checkWaylandWindowsKDE = "qdbus org.kde.KWin /KWin org.kde.KWin.showDebugConsole";
          # TODO: gifsicle -O3 --lossy=30 noita-20240328-191617-1612416266-00316616.gif -o noita-20240328-191617-1612416266.gif 
          ssh = "TERM=xterm-256color ssh";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "eastwood";
      };
    };
}
