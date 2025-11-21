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
    rev = "ba5cc7b417cc5982bd547ff1304111daf4c7d99b";
  };
  installPhase = ''
    mkdir -p $out
    cp -r src/* $out
  '';
})
