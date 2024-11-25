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
    rev = "37408a1b35af0c84faeea60cdb94f321bbff6ef7";
  };
  installPhase = ''
    mkdir -p $out
    cp -r src/* $out
  '';
})
