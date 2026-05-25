{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "qbittorrent";
  cfg = config.custom.services.${name};
in
{

  options.custom.services.${name} = {
    enable = lib.mkEnableOption "Enables qbittorrent";
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/seed/qb";
      description = "Directory to store uploaded files";
    };
  };

  config = lib.mkIf cfg.enable {
    # systemd.tmpfiles.rules = [ "d /hdd/seed 0700 ${config.services.qbittorrent.user} ${config.services.transmission.group} -" ];
    #  https://raw.githubusercontent.com/Naunter/BT_BlockLists/master/bt_blocklists.gz
    users.users.qbittorrent.extraGroups = [ "torrent" ];

  networking.firewall.extraInputRules = ''
    ip saddr ${config.custom.vars.internalCidr} tcp dport ${toString config.services.qbittorrent.webuiPort} counter accept comment allow_from_internal
  '';
    users.groups = {
      torrent = {
        gid = config.custom.vars.gids.torrent;
      };
    };
    services.qbittorrent = {
      enable = true; # Enable qbittorrent daemon
      webuiPort = 8080;
    };
  };
}
