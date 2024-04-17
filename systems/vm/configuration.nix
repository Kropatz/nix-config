{pkgs, config, ...}:
{

  mainUser.layout = "de";
  mainUser.variant = "us";
  custom = {
    user = {
      name = "vm";
      layout = "de";
      variant = "us";
    };
    cli-tools.enable = true;
    nix = {
      index.enable = true;
      ld.enable = true;
      settings.enable = true;
    };
    graphical = {
      plasma.enable = true;
      shared.enable = true;
    };
  };
}
