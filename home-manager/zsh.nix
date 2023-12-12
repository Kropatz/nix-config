{ user, pkgs, ... }:
{
  home-manager.users.${user} = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      shellAliases = {
          ll = "ls -l";
          update = "sudo nixos-rebuild switch";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "eastwood";
      };
    };
  };
}
