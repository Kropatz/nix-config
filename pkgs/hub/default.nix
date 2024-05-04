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
    rev = "39cadbabb0a9b038aa40a586178323b2981595dd";
  };
  installPhase = ''
    mkdir -p $out
    cp -r src/* $out
  '';
})
