{
  buildGoModule,
  stdenv,
  pkgs,
  lib,
  ...
}:
buildGoModule rec {
  pname = "kop-minihttp";
  version = "0.0.1";

  src = fetchGit {
    url = "ssh://gitea@git.kopatz.dev/kopatz/kop-minihttp.git";
    ref = "master";
    rev = "5caa395fe58b5b84da4e77b174376104e24f16a9";
  };
  vendorHash = null;

  postInstall = ''
    mv $out/bin/kopminihttp $out/bin/kop-minihttp
  '';

  meta = {
    description = "Simple static HTTP server";
    homepage = "";
    license = lib.licenses.gpl3;
  };
}
