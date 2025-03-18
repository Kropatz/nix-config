# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, inputs, ... }: #nixos-wsl, ... }:

{
  imports = [
    # include NixOS-WSL modules
    #   <nixos-wsl/modules>
  ];

  wsl = {
    enable = true;
    nativeSystemd = true;
    startMenuLaunchers = true;
    wslConf = {
      automount.root = "/mnt";
      user.default = lib.mkForce "anon";
      interop = { enabled = false; appendWindowsPath = false; };
    };
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.trusted-substituters = [ "https://ai.cachix.org" ];
  nix.settings.trusted-public-keys = [ "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc=" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    openssh
  ];

  networking.hostName = "wsl";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
