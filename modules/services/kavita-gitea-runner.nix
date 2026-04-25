{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.kavita-gitea-runner;
in
{
  options.custom.services.kavita-gitea-runner = {
    enable = mkEnableOption "Enables kavita runner";
    dir = mkOption {
      default = "/data/shares/exposedvm/kavita";
      type = types.path;
      description = "data path";
    };
  };
  config =
    let
      baseDir = cfg.dir;
    in
    lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d ${baseDir} 0750 exposedvm gitea-actions-runner -"
        "d ${baseDir}/github 0770 exposedvm gitea-actions-runner -"
      ];

      systemd.services.gitea-runner-oberprofis = {
        serviceConfig.ReadWritePaths = [ "${cfg.dir}/github" ];
      };

      users.users.kavita = {
        isSystemUser = true;
        group = "kavita";
        uid = 2001;
      };

      users.groups.kavita = {
        gid = 2001;
      };
    };
}
