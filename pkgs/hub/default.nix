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
    rev = "e84a5f44acddf6216a927b8938b02bc5aaba6e3e";
  };
  installPhase = ''
    mkdir -p $out
    cp -r src/* $out
  '';
})
