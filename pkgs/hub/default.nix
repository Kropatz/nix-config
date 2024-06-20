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
    rev = "062c128597e2b2e4275f7c8ce27644cdc6b5e49b";
  };
  installPhase = ''
    mkdir -p $out
    cp -r src/* $out
  '';
})
