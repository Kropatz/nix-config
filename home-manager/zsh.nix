{ config, pkgs, inputs, ...}:
{
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      shellAliases = {
          ll = "ls -l";
          update = "sudo nixos-rebuild switch";
          updateOffline = "sudo nixos-rebuild switch --option substitute false";
          checkTime = "(cd ~/Nextcloud/work_drive/TS && nix run)";
          ssh="TERM=xterm-256color ssh";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "eastwood";
      };
    };
}
