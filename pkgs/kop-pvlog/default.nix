{
  buildGoModule,
  stdenv,
  pkgs,
  lib,
  ...
}:
buildGoModule rec {
  pname = "kop-pvlog";
  version = "0.0.1";

  src = fetchGit {
    url = "gitolite@kopatz.dev:kop-pvlog.git";
    ref = "master";
    rev = "2bb67c4b27bba9b99cf2182f989a53bb7f346659";
  };
  vendorHash = "sha256-8wYERVt3PIsKkarkwPu8Zy/Sdx43P6g2lz2xRfvTZ2E=";

  meta = {
    description = "Fronius Inverter data logger";
    license = lib.licenses.gpl3;
  };
}
