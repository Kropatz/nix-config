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
    rev = "fd5b5a1eb29e2ee41352dc320d6ed0d855666270";
  };
  installPhase = ''
    mkdir -p $out
    cp -r src/* $out
  '';
})
