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
      programs.lf = {
        enable = true;
        previewer.source = pkgs.writeShellScript "pv.sh" ''
          #!/bin/sh
          case "$(${pkgs.file}/bin/file -Lb --mime-type -- "$1")" in
            #image/*|video/*) ${pkgs.chafa}/bin/chafa -f sixel -s "$2x$3" --animate false $1;;
            application/x-tar) tar tf "$1";;
            application/vnd.rar) ${pkgs.p7zip}/bin/7z l "$1";;
            application/x-7z-compressed) ${pkgs.p7zip}/bin/7z l "$1";;
            *) ${pkgs.ctpv}/bin/ctpv "$1";;
          esac
        '';
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
