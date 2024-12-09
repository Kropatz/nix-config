{ osConfig, config, pkgs, inputs, lib, ... }: {
  config = lib.mkIf osConfig.custom.graphical.code.enable {
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
