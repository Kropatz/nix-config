{ osConfig, config, pkgs, inputs, lib, ... }: {
  config = lib.mkIf osConfig.custom.graphical.code.enable rec {
    home.activation.makeVSCodeConfigWritable = let
      configDirName = {
        "vscode" = "Code";
        "vscode-insiders" = "Code - Insiders";
        "vscodium" = "VSCodium";
      }.${programs.vscode.package.pname};
      configPath =
        "${config.xdg.configHome}/${configDirName}/User/settings.json";
    in {
      after = [ "writeBoundary" ];
      before = [ ];
      data = ''
        if [ -e "$(readlink ${configPath})" ]; then
          install -m 0640 "$(readlink ${configPath})" ${configPath}
        fi
      '';
    };
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
        "clangd.path" = "/run/current-system/sw/bin/clangd";
      };
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        #rust-lang.rust-analyzer broken on unstable
        myriad-dreamin.tinymist
        #tomoki1207.pdf latex-workshop is faster to preview pdf
        james-yu.latex-workshop
        twxs.cmake
        llvm-vs-code-extensions.vscode-clangd
      ];
    };
  };
}
