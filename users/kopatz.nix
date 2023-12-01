{ pkgs, inputs, ... }:
let 
  user = "kopatz";
in
{
  imports = [
    (
      import ./home-manager/nvim/nvim.nix ({ user="${user}"; pkgs = pkgs; })
    )
    (
      import ./home-manager/vscode/code.nix ({ user="${user}"; pkgs = pkgs; })
    )
  ];
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
      headless = false;
    };
    useUserPackages = true;
    users.${user} = {
      gtk = {
        enable = true;
        theme = { 
          name = "palenight";
          package = pkgs.palenight-theme;
        };
        cursorTheme = {
          package = pkgs.libsForQt5.breeze-gtk;
          name = "Breeze-gtk";
        };
      };
      
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
      programs.git.enable = true;
      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
      home.stateVersion = "23.05";
    };
  };
  
  programs.zsh.enable = true;
  users.users.${user} = {
    isNormalUser = true;
    description = user;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" ];
    packages = with pkgs; [
      (discord.override { withVencord = true; })
      librewolf
      brave
    ];
    openssh.authorizedKeys.keys = [
       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeP6qtVqE/gu72ZUZE8cdRi3INiUW9NqDR7SjXIzTw2 lukas"
    ];
  };
}
