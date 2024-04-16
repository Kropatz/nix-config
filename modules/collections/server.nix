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
    ../cli-tools.nix
    ../cron.nix
    ../docker.nix
    ../fail2ban.nix
    ../firewall.nix
    ../git.nix
    ../hdd-spindown.nix
    ../logging.nix
    ../motd.nix
    ../nix/settings.nix
    ../static-ip.nix
    ### Hardware ###
    ../hardware/ssd.nix
  ];

  kop.tmpfs.enabled = true;
}
