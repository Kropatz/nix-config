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
    rev = "62dd0ddbaa4c12dc0588bc8086d77a7e04be9c76";
  };
  vendorHash = "sha256-8wYERVt3PIsKkarkwPu8Zy/Sdx43P6g2lz2xRfvTZ2E=";

  meta = {
    description = "Fronius Inverter data logger";
    license = lib.licenses.gpl3;
  };
}
