{ config, pkgs, ... }:

{
  system.stateVersion = "24.11";

  # simple auto-login user so you land in a shell
  users.users.demo = {
    isNormalUser = true;
    password = "demo";
    extraGroups = [ "wheel" ];
  };
  services.getty.autologinUser = "root";
  security.sudo.wheelNeedsPassword = false;

  services.syncthing = {
    enable = true;
    user = "demo";
    group = "users";
    guiAddress = "/var/lib/syncthing/gui.sock";
    settings = {
      options.urAccepted = -1;
      options.relaysEnabled = false;
      options.globalAnnounceEnabled = false;
      options.crashReportingEnabled = false;
    };
  };

  # make sure /run/syncthing and /var/lib/syncthing exist and are
  # owned by the service user
  systemd.services.syncthing.serviceConfig = {
    RuntimeDirectory = "syncthing";
    StateDirectory = "syncthing";
    StateDirectoryMode = "0700";
  };

  # a couple of handy tools inside the VM
  environment.systemPackages = with pkgs; [
    curl
    socat
  ];

  # VM-only settings (used by nixos-rebuild build-vm / -A vm)
  virtualisation.vmVariant = {
    virtualisation.memorySize = 1024;
    virtualisation.cores = 2;
    virtualisation.graphics = false; # serial console in your terminal
  };
}
