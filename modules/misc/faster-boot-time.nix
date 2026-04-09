{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "fasterboot";
  cfg = config.custom.misc.${name};
in
{

  options.custom.misc.${name} = {
    enable = lib.mkEnableOption "Enables faster boot";
  };

  config = lib.mkIf cfg.enable {
    # before: Startup finished in 18.830s (firmware) + 5.844s (loader) + 4.422s (kernel) + 7.616s (userspace) = 36.713s
    # after: Startup finished in 14.115s (firmware) + 789ms (loader) + 4.312s (kernel) + 5.777s (userspace) = 24.995s
    systemd = {
      targets.network-online.wantedBy = lib.mkForce [ ]; # Normally ["multi-user.target"]
      services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ]; # Normally ["network-online.target"]
    };
    # mash spacebar to still be able to select a different boot option
    boot.loader.timeout = lib.mkDefault 1;

    virtualisation.docker.enableOnBoot = false;
  };
}
