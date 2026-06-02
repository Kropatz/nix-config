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
  options.custom.graphical.code = {
    enable = mkEnableOption "Enables code";
    rider = mkEnableOption "Enables Rider";
    clion = mkEnableOption "Enables Clion";
  };

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
        (claude-code.overrideAttrs {
          version = "2.1.159";
          src = fetchurl {
            url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.159/linux-x64/claude";
            sha256 = "e2126caf00ed3ec09371a29947658c7e9b31185256b2ac5728263bd95f7e3541";
          };
        })
        #unstable-small.zed-editor
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
