{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.graphical.code;
in
{

  config = mkIf cfg.enable {
    documentation.dev.enable = true;
    environment.systemPackages =
      with pkgs;
      [
        man-pages
        jetbrains.idea
        typescript
        bruno
        nodejs
        python3
        gcc
        opencode
        zed-editor
        lazygit
        (claude-code.overrideAttrs {
          version = "2.1.201";
          src = fetchurl {
            url = "https://downloads.claude.ai/claude-code-releases/2.1.201/linux-x64/claude";
            sha256 = "sha256-o0gJpoOf3v/yG5NH1/tba1jmqcwgil5ihT8pyD6xB6M=";
          };
        })
        (pkgs.writeShellScriptBin "devc" ''
          IS_RUNNING=$(docker ps --filter status=running | grep dev)
          if [ $? -eq 0 ]; then
            docker exec -it dev bash
            exit 0
          fi
          cd ~/projects/selfhosted/stuff/devcontainer
          ./docker.sh
        '')
      ]
      ++ [
        nixd
        csharp-ls
        tinymist
        dart
        gotools
        gopls
        rust-analyzer
        typescript-language-server
        bash-language-server
        python313Packages.python-lsp-server
        clang-tools
        jdt-language-server
        angular-language-server
      ]
      ++ lib.optionals cfg.rider [
        pkgs.jetbrains.rider
      ]
      ++ lib.optionals cfg.clion [
        pkgs.jetbrains.clion
      ];

    #environment.sessionVariables = {
    #  DOTNET_ROOT = "${pkgs.dotnet-sdk_7}";
    #};
  };
}
