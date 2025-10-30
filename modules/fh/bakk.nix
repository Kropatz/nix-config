{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.postgresql = {
    enable = true;
    extensions = with pkgs.postgresql14Packages; [ pg_libversion ];
    authentication = pkgs.lib.mkOverride 10 ''
      #TYPE  DATABASE   USER    ADDRESS        METHOD
      local all         all                    trust
      host  all         all     127.0.0.1/32   trust
    '';
  };
}
