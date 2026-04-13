{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.custom.services.gitea-runner;
in
{
  options.custom.services.gitea-runner = {
    enable = lib.mkEnableOption "Enables gitea-runner service.";
    workDir = lib.mkOption {
      type = lib.types.str;
      default = "/1tbssd/gitea-actions-runner";
      description = "Directory for gitea runner.";
    };
  };
  config = lib.mkIf cfg.enable {

    users.groups.gitea-actions-runner = { };
    users.users.gitea-actions-runner = {
      isSystemUser = true;
      hashedPasswordFile = config.age.secrets.gitea-runner-pw.path;
      home = cfg.workDir;
      group = "gitea-actions-runner";
      extraGroups = [ "docker" ];
    };
    age.secrets.gitea-runner-token = {
      file = ../../secrets/gitea-runner-token.age;
      owner = "gitea-actions-runner";
      group = "gitea-actions-runner";
    };
    age.secrets.gitea-runner-pw = {
      file = ../../secrets/github-runner-pw.age;
      owner = "gitea-actions-runner";
      group = "gitea-actions-runner";
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.workDir} 0770 gitea-actions-runner gitea-actions-runner -"
    ];
    services.gitea-actions-runner.instances.oberprofis = {
      enable = true;
      name = "nixos-server";
      tokenFile = config.age.secrets.gitea-runner-token.path;
      labels = [
        "native:host"
        "self-hosted"
        "Linux"
      ];
      url = "https://git.kopatz.dev";
      hostPackages = with pkgs; [
        bash
        coreutils
        curl
        gawk
        gitMinimal
        gnused
        nodejs
        wget
        rsync
        pnpm
        nodejs
      ];
    };
    systemd.services.gitea-runner-oberprofis = {
      environment = {
        HOME = lib.mkForce cfg.workDir;
        STATE_DIRECTORY = cfg.workDir;
      };
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = lib.mkForce "gitea-actions-runner";
        Group = "gitea-actions-runner";
        WorkingDirectory = lib.mkForce "${cfg.workDir}/oberprofis";
        BindPaths = [
          "${cfg.workDir}"
        ]
        ++ lib.optional config.custom.services.kavita.enable config.custom.services.kavita.dir;
        ReadWritePaths = [
          "${cfg.workDir}"
        ]
        ++ lib.optional config.custom.services.kavita.enable config.custom.services.kavita.dir;
        UMask = "022";
        InaccessiblePaths = [
          "-/data/synced"
          "-/data/vmail"
          "-/data/comms"
          "-/1tbssd/data"
          "-/hdd"
        ];
      };
    };
  };
}
