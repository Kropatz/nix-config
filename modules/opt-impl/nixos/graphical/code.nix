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
        nodejs_22 # needed for tabby extension
        python3
        gcc
        opencode
        zed-editor
        lazygit
        (claude-code.overrideAttrs {
          version = "2.1.170";
          src = fetchurl {
            url = "https://downloads.claude.ai/claude-code-releases/2.1.170/linux-x64/claude";
            sha256 = "sha256-hJ4AcnegRCqydXDT49bUN4dQeUZZDo3RlH5aObcIH54=";
          };
        })
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
