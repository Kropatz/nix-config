{
  stdenv,
  lib,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hub";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:oberprofis/hub.git";
    ref = "master";
    rev = "e180ad2fbdfef9c9845765aab313f84b161d9447";
  };
  installPhase = ''
    mkdir -p $out
    cp -r src/* $out
  '';
})
