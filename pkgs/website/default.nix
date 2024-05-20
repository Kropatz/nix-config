{ stdenv, lib, buildNpmPackage, fetchFromGitHub, kop-hub, ente-frontend }:

stdenv.mkDerivation (finalAttrs: {
  pname = "kopatz-website";
  version = "1.0.0";

  src = ./.;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/tracker-site
    cp -r ${kop-hub}/* $out
    cp -r ${ente-frontend}/* $out/tracker-site
  '';
})
