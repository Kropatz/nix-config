{ osConfig, config, pkgs, inputs, lib, ... }: {
  config = lib.mkIf osConfig.custom.graphical.code.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      userSettings = { typst-lsp.exportPdf = "onType"; };
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        rust-lang.rust-analyzer
        nvarner.typst-lsp
        #tomoki1207.pdf latex-workshop is faster to preview pdf
        james-yu.latex-workshop
      ];
    };
  };
}
