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
    url = "ssh://gitea@git.kopatz.dev/kopatz/kop-pvlog.git";
    ref = "master";
    rev = "b3a46f5eb9ad2dacf025db59645415a215997d18";
  };
  vendorHash = "sha256-8wYERVt3PIsKkarkwPu8Zy/Sdx43P6g2lz2xRfvTZ2E=";

  meta = {
    description = "Fronius Inverter data logger";
    license = lib.licenses.gpl3;
  };
}
