{
  pkgs,
  config,
  lib,
  ...
}:
let
  backupCfg = config.custom.misc.backup;
in
{
  options.custom = {
    cli-tools = {
      enable = lib.mkEnableOption "Enables cli-tools";
      saveSpace = lib.mkEnableOption "Saves disk space by skipping some packages.";
    };
    nftables.enable = lib.mkEnableOption "Enables nftables";
    nixvimPlugins = lib.mkEnableOption "Enables nixvim plugins";
    static-ip = {
      enable = lib.mkEnableOption "Enables static-ip";
      ip = lib.mkOption {
        type = lib.types.str;
        description = "ipv4 address";
      };
      dns = lib.mkOption {
        type = lib.types.str;
        description = "ip of the dns server";
      };
      interface = lib.mkOption {
        type = lib.types.str;
        description = "interface to apply the change to";
      };
      renameInterface = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Rename the interface to eth0.";
      };
      gateway = lib.mkOption {
        type = lib.types.str;
        default = "192.168.0.1";
        description = "Default gateway";
      };
    };
    tmpfs.enable = lib.mkEnableOption "Enables tmpfs";
    virt-manager.enable = lib.mkEnableOption "Enables virt-manager";
    wireshark.enable = lib.mkEnableOption "Enables wireshark";

    misc = {
      backup = {
        enable = lib.mkEnableOption "Enables backup";
        small = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "paths to include in the small backup";
        };
        medium = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = backupCfg.small;
          description = "paths to include in the medium backup";
        };
        large = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = backupCfg.small // backupCfg.medium;
          description = "paths to include in the large backup";
        };
        excludePaths = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "**/Cache"
            "**/.cache"
            "**/__pycache__"
            "**/node_modules"
            "**/venv"
            "*.o"
            "*.out"
          ];
          description = "paths to exclude from the backup";
        };
        excludePathsRemote = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = backupCfg.excludePaths ++ [ "**/dont_remotebackup" ];
          description = "paths to exclude from the remote backup";
        };
      };
      btrfs.enable = lib.mkEnableOption "Enables btrfs scrubbing";
      docker.enable = lib.mkEnableOption "Enables docker";
      fasterboot.enable = lib.mkEnableOption "Enables faster boot";
      firejail = {
        enable = lib.mkEnableOption "Enables firejail";
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.firejail;
          description = "Firejail package used";
          readOnly = true; # is a constant from the upstream NixOS module for now
        };
        mk = lib.mkOption {
          readOnly = true;
          description = "Utility function to make a wrappedBinaries entry";
          default =
            name:
            {
              pkg,
              profile ? name,
              bin ? name,
            }:
            {
              ${bin} = {
                executable = "${lib.getBin pkg}/bin/${bin}";
                profile = "${config.custom.misc.firejail.package}/etc/firejail/${profile}.profile";
              };
            };
        };
      };
      hardening.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable hardening options.";
      };
      newkernel.enable = lib.mkEnableOption "Enables new kernel";
      podman.enable = lib.mkEnableOption "Enable podman service";
      zram.enable = lib.mkEnableOption "Enables zram";
    };
  };
}
