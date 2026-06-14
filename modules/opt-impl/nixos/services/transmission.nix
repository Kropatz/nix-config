{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "transmission";
  cfg = config.custom.services.${name};
in
{

  config = lib.mkIf cfg.enable {
    # systemd.tmpfiles.rules = [ "d /hdd/seed 0700 ${config.services.transmission.user} ${config.services.transmission.group} -" ];
    #  https://raw.githubusercontent.com/Naunter/BT_BlockLists/master/bt_blocklists.gz

    users.users.transmission.extraGroups = [ "torrent" ];
    users.groups = {
      torrent = {
        gid = config.custom.vars.gids.torrent;
      };
    };
    services.transmission = {
      enable = true; # Enable transmission daemon
      openRPCPort = true; # Open firewall for RPC
      package = pkgs.transmission_4;
      settings = {
        rpc_authentication_required = true;
        rpc_password = "{d154a020c43f402590fc927ede081aaecb65be85it30UVNL";
        ratio-limit-enabled = true;
        incomplete-dir-enabled = false;
        download-dir = cfg.dataDir;
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist = "127.0.0.1,192.168.0.11,192.168.2.22";
      };
    };
  };
}
