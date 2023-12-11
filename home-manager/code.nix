
{ user, pkgs, ... }:
{
  home-manager.users.${user} = {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        rust-lang.rust-analyzer
     ];
    };
  };
}
