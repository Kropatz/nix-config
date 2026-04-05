{ pkgs, ... }:
let
  mkShellSnippet = ''
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node

    ls.add_snippets("nix", {
      s("mkShell", {
        t({ "{ pkgs ? import <nixpkgs> {} }:", "", "pkgs.mkShell {", "  packages = with pkgs; [", "    " }),
        i(1, "# packages here"),
        t({ "", "  ];", "", "  shellHook =", "    let",
          "      libraries = with pkgs; [ ",
        }),
        i(2, ""),
        t({ " ];", "    in", "    '''", "      export LD_LIBRARY_PATH=''${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH", "", "    ''';", "}" }),
      }),
      s("mkModule", {
        t({ "{", "  config,", "  pkgs,", "  inputs,", "  system,", "  lib,", "  ...", "}:",
          "let", "  name = \"",
        }),
        i(1, "service-name"),
        t({ "\";", "  cfg = config.custom.services.''${name};", "in", "{", "",
          "  options.custom.services.''${name} = {", "    enable = lib.mkEnableOption \"Enables " }),
        i(2, "service-name"),
        t({ "\";", "  };", "",
          "  config = lib.mkIf cfg.enable {", "",
          "  };", "}" }),
      }),
    })
  '';
in
{
  plugins = {
    luasnip = {
      enable = true;
      settings = {
        enable_autosnippets = true;
        store_selection_keys = "<Tab>";
      };
      extraConfigPaths = [ ];
    };
  };
  extraConfigLua = mkShellSnippet;
}
