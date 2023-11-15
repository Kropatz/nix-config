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
      discord
      librewolf
      ungoogled-chromium
    ];
  };
}
