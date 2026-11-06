{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
let
  name = "ssh";
  cfg = config.custom.services.${name};
in
{
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.openssh = {
      enable = true;
      allowSFTP = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password";
      };
      extraConfig = ''
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
      '';
    };
  };
}
