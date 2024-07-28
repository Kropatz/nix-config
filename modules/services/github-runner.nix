{ config, pkgs, lib, inputs, ... }:
let cfg = config.custom.services.github-runner;
in {
  options.custom.services.github-runner = {
    enable = lib.mkEnableOption "Enables github-runner service.";
  };
  config = lib.mkIf cfg.enable {
    nixpkgs.config.permittedInsecurePackages = [ "nodejs-16.20.2" ];

    users.groups.github-actions-runner = { };
    users.users.github-actions-runner = {
      isSystemUser = true;
      hashedPasswordFile = config.age.secrets.github-runner-pw.path;
      group = "github-actions-runner";
      extraGroups = [ "docker" ];
    };
    age.secrets.github-runner-token = {
      file = ../../secrets/github-runner-token.age;
      owner = "github-actions-runner";
      group = "github-actions-runner";
    };
    age.secrets.github-runner-pw = {
      file = ../../secrets/github-runner-pw.age;
      owner = "github-actions-runner";
      group = "github-actions-runner";
    };
    systemd.tmpfiles.rules = [
      "d /github-actions-runner 0770 github-actions-runner github-actions-runner -"
    ];
    services.github-runners.oberprofis = {
      enable = true;
      name = "nixos-server";
      tokenFile = config.age.secrets.github-runner-token.path;
      url = "https://github.com/oberprofis";
      user = "github-actions-runner";
      workDir = "/github-actions-runner";
      extraPackages = with pkgs; [ rsync nodePackages.pnpm nodejs_18 ];
      serviceOverrides = {
        BindPaths = [ "/github-actions-runner" ]
          ++ lib.optional config.custom.services.kavita.enable
          config.custom.services.kavita.dir;
        UMask = "022";
      };
    };
  };
}
