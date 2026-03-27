{
  stdenv,
  lib,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hub";
  version = "1.0.0";

  src = fetchGit {
    url = "gitea@git.kopatz.dev:oberprofis/hub";
    ref = "master";
    rev = "eb71c6bc0af81097346397960a68eaa5a661d034";
  };
  installPhase = ''
    mkdir -p $out
    cp -r src/* $out
  '';
})
