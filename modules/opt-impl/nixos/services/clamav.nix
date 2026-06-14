{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.clamav;
in
{
  config = lib.mkIf cfg.enable {
    services.clamav = {
      scanner.enable = cfg.enableScanner;
      scanner.scanDirectories = cfg.scanDirectories;
      updater.enable = true;
      daemon = {
        enable = true;
        settings = {
          ExcludePath = [
            "^/proc"
            "^/dev"
            "^/sys"
            "^/var/lib/docker"
            "^/var/lib/samba/private"
            "^/var/lib/samba/winbindd_privileged/pipe"
            "^/var/lib/postfix/queue/"
            "^/var/lib/docker/overlay2"
            "^/var/lib/docker/volumes/backingFsBlockDev"
            "^/var/lib/rspamd/rspamd.sock"
            "^/tmp/tmux-.*"
            "^/tmp/.*dotnet-diagnostic-.*"
            "^/tmp/.*clr-debug-pipe-.*"
            "^/tmp/.*plugin[0-9]+"
          ];
        };
      };
    };
  };
}
