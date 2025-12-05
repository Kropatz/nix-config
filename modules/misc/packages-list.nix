{ config, pkgs, ... }:
{
  environment.etc."current-system-packages".text =
    let
      packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
      homePackages = builtins.map (p: "${p.name}") config.home-manager.users.${config.mainUser.name}.home.packages;
      sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique (packages ++ homePackages));
      formatted = builtins.concatStringsSep "\n" sortedUnique;
    in
    formatted;
}
