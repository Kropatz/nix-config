{ pkgs, ... }:
let
  # in-buffer fit-to-width markdown table renderer
  md-table-fit = pkgs.vimUtils.buildVimPlugin {
    pname = "md-table-fit";
    version = "0.1.0";
    src = ./md-table-fit;
  };
  # cursortabSrc = pkgs.fetchFromGitHub {
  #   owner = "cursortab";
  #   repo = "cursortab.nvim";
  #   rev = "53c336bd01afa9160935e4423a424c2adc8160be";
  #   hash = "sha256-MTRz8vPJ+mo6K4dWNlTtxZcEA+pSHWp4cJs/WQTl1H4=";
  # };
  #
  # # Requires a stable Go toolchain
  # cursortab-server = pkgs.buildGo125Module {
  #   pname = "cursortab-server";
  #   version = "0.8.0";
  #   src = cursortabSrc;
  #   modRoot = "server";
  #   vendorHash = "sha256-4S14Vm2Ju084uxB2Zlku4z5AmIZkNZkQpiNgYrcqIbg=";
  # };
  # cursortab = pkgs.vimUtils.buildVimPlugin {
  #   pname = "cursortab.nvim";
  #   version = "0.8.0";
  #   src = cursortabSrc;
  #   postInstall = ''
  #     mkdir -p $out/server
  #     ln -s ${pkgs.lib.getExe' cursortab-server "cursortab"} $out/server/cursortab
  #   '';
  # };
in
{
  extraPlugins = [
    md-table-fit
    # cursortab
  ];
  extraConfigLua = ''
    require("md-table-fit").setup({})
    -- require("cursortab").setup({
    --   provider = {
    --     type = "zeta-2.1",
    --     url = "http://localhost:4442",
    --   },
    -- })
  '';
}
