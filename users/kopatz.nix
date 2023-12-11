{ pkgs, inputs, vars, ... }:
let 
  user = "kopatz";
in
{
  imports = [
    (import ../home-manager/nvim.nix ({ user="${user}"; pkgs = pkgs; }))
    (import ../home-manager/code.nix ({ user="${user}"; pkgs = pkgs; }))
    (import ../home-manager/zsh.nix ({ user="${user}"; pkgs = pkgs; }))
    (import ../home-manager/gtk-theme.nix ({ user="${user}"; pkgs = pkgs; }))
    (import ../home-manager/direnv.nix ({ user="${user}"; pkgs = pkgs; }))
    (import ../home-manager/lf.nix ({ user="${user}"; pkgs = pkgs; }))
  ];

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
      headless = false;
    };
    useUserPackages = true;
    users.${user} = {
      programs.git.enable = true;
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
