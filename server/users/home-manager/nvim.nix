{
  home-manager.users.anon = { pkgs, ...}: {
    programs.neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        (nvim-treesitter.withAllGrammars)
      ];
      extraPackages = with pkgs;
        [];
      extraConfig = ''
      '';
    };
  };
}
