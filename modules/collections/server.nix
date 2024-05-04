{pkgs, ...}:
{
  imports = [
    ### Services ###
    ../services/adguard.nix
    ../services/github-runner.nix
    ../services/gitolite.nix
    # wait for https://github.com/NixOS/nixpkgs/pull/300228
    ../services/grafana.nix
    #../services/nextcloud.nix
    #../services/samba.nix
    ../services/ssh.nix
    ../services/step-ca.nix
    ../services/syncthing.nix
    #../services/syncthing.nix
    ../services/wireguard.nix
    ### Other Modules ###
    #../games/palworld.nix
    ../backup.nix
    ../cron.nix
    ../fail2ban.nix
    ../firewall.nix
    ../git.nix
    ../hdd-spindown.nix
    ../logging.nix
    ../motd.nix
  ];

  custom = {
    cli-tools.enable = true;
    tmpfs.enable = true;
    static-ip = {
      enable = true;
      interface = "enp0s31f6";
      ip = "192.168.0.6";
      dns = "127.0.0.1";
    };
    nix = {
      settings.enable = true;
    };
    services = {
      acme.enable = true;
      nginx.enable = true;
      kavita = {
        enable = true;
        dir = "/mnt/1tbssd/kavita";
      };
    };
    misc = {
      docker.enable = true;
    };
    hardware = {
      firmware.enable = true;
      ssd.enable = true;
    };
  };
}
