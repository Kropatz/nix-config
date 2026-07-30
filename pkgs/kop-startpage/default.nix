{
  stdenv,
  lib,
  ...
}:
stdenv.mkDerivation {
  pname = "kop-startpage";
  version = "0.0.1";

  src = fetchGit {
    url = "gitea@git.kopatz.dev:kopatz/kop-startpage.git";
    ref = "master";
    rev = "265c7b2616d99ee31e4674e530a00d9c83acba58";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r ./* $out
  '';

  meta = {
    description = "Browser startpage";
    license = lib.licenses.gpl3;
  };
}
