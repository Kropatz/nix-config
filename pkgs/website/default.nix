{ stdenv, lib, buildNpmPackage, fetchFromGitHub, hub, ente-frontend }:

stdenv.mkDerivation (finalAttrs: {
  pname = "kopatz-website";
  version = "1.0.0";

  src = ./.;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/tracker-site
    cp -r ${hub}/* $out
    cp -r ${ente-frontend}/* $out/tracker-site
  '';
})
