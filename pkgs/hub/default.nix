{
  stdenv,
  lib,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hub";
  version = "1.0.0";

  src = fetchGit {
    url = "ssh://gitea@git.kopatz.dev/oberprofis/hub";
    ref = "master";
    rev = "81e3f77e8837fec7fb2b0d63a70a8763bb9ec578";
  };
  installPhase = ''
    mkdir -p $out
    cp -rT src $out
  '';
})
