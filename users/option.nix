{lib, config, pkgs, ...}:
{
  options.mainUser = {
    name = lib.mkOption {
      default = "mainuser";
      description = ''
        username
      '';
    };
    layout = lib.mkOption {
      default = "de";
      description = "keyboard layout";
    };
    variant = lib.mkOption {
      default = "";
      description = "keyboard variant";
    };
    sshKey = lib.mkOption {
      default = throw "No ssh key specified";
      description = "Public key of the user";
    }
  };
}
