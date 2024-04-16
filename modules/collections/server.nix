{pkgs, ...}:
{
  imports = [
    ### Services ###
    ../services/acme.nix
    ../services/adguard.nix
    ../services/github-runner.nix
    ../services/gitolite.nix
    # wait for https://github.com/NixOS/nixpkgs/pull/300228
    ../services/kavita.nix
    ../services/grafana.nix
    #../services/nextcloud.nix
    ../services/nginx.nix
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
    ../docker.nix
    ../fail2ban.nix
    ../firewall.nix
    ../git.nix
    ../hdd-spindown.nix
    ../logging.nix
    ../motd.nix
    ../static-ip.nix
  ];

  kop = {
    cli-tools.enable = true;
    tmpfs.enable = true;
    nix = {
      settings.enable = true;
    };
    hardware = {
      firmware.enable = true;
      ssd.enable = true;
    };
  };
}
