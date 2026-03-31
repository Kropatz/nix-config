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
