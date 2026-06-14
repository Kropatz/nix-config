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
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      settings.X11Forwarding = false;
      settings.PermitRootLogin = "prohibit-password";
      extraConfig = ''
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
      '';
    };
  };
}
