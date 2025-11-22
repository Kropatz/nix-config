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
    rev = "e4063057b6e77c0b81d991cda8ad5225e2dbdf59";
  };
  vendorHash = "sha256-8wYERVt3PIsKkarkwPu8Zy/Sdx43P6g2lz2xRfvTZ2E=";

  meta = {
    description = "Fronius Inverter data logger";
    license = lib.licenses.gpl3;
  };
}
