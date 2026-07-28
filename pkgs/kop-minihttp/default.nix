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
    url = "gitea@git.kopatz.dev:kopatz/kop-minihttp.git";
    ref = "master";
    rev = "89df4a72bb9cfff3c0e2618d94feb269aefc439c";
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
