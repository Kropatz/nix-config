{ osConfig, config, pkgs, inputs, lib, ... }: {
  config = lib.mkIf osConfig.custom.graphical.code.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      #userSettings = { typst-lsp.exportPdf = "onType"; };
      userSettings = {
        "Lua.workspace.library" = [
          "/home/kopatz/.vscode-oss/extensions/evaisa.vscode-noita-api-1.4.2/out/NoitaLua"
        ];
        "editor.mouseWheelZoom" = true;
        "files.autoSave" = "afterDelay";
      };
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        #rust-lang.rust-analyzer broken on unstable
        myriad-dreamin.tinymist
        #tomoki1207.pdf latex-workshop is faster to preview pdf
        james-yu.latex-workshop
      ];
    };
  };
}
