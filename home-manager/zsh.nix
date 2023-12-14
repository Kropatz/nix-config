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
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "eastwood";
      };
    };
}
