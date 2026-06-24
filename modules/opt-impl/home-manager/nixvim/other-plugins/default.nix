{ pkgs, ... }:
let
  # in-buffer fit-to-width markdown table renderer
  md-table-fit = pkgs.vimUtils.buildVimPlugin {
    pname = "md-table-fit";
    version = "0.1.0";
    src = ./md-table-fit;
  };
in
{
  extraPlugins = [
    md-table-fit
  ];
  extraConfigLua = ''
    require("md-table-fit").setup({})
  '';
}
