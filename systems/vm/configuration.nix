{ pkgs, config, lib, ... }: {

  imports = [ ./vm-common.nix ];
  age.identityPaths = [ /home/kopatz/.ssh/id_rsa ];
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
      i3.enable = true;
    };
  };
  networking.networkmanager.enable = true;


  environment.systemPackages = with pkgs; [ firefox ];

}
