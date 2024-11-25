{ stdenv
, lib
, ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hub";
  version = "1.0.0";

  src = fetchGit {
    url = "git@github.com:oberprofis/hub.git";
    ref = "master";
    rev = "8b689e230a8ecbc85d4e2eae7544018ccefc735a";
  };
  installPhase = ''
    mkdir -p $out
    cp -r src/* $out
  '';
})
