{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "audit";
  cfg = config.custom.services.${name};
in
{
  config = lib.mkIf cfg.enable {
    security.auditd.enable = true;
    environment.etc."audit/auditd.conf".text = ''
      space_left = 10%
      space_left_action = ignore
      #admin_space_left = 5%
      #admin_space_left_action = email
      #action_mail_acct = root
      num_logs = 10
      max_log_file = 100
      max_log_file_action = rotate
    '';
    security.audit = {
      enable = true;
      rules = [
        # TODO:
        # track audit itself accesses
        # track shm accesses
        # track mount/unmount
        # track usb keys accesses
        # track kernel module loading
        # track kexec operations
        # track network cards changes
        # track thunderbolt changes
        # This tracks only all execve for now, which is not that bad.
        "-a exit,always -F arch=b64 -S execve"
      ];
    };
  };
}
